local core = assert(l2df, 'L2DF is not available')
local data = assert(data, 'Shared data is not available')

local log = core.import 'class.logger'
local cfg = core.import 'config'
local helper = core.import 'helper'

local Scene = core.import 'class.entity.scene'
local Parser = core.import 'class.parser.lffs2'
local Controller = core.import 'class.component.controller'
local Factory = core.import 'manager.factory'
local Input = core.import 'manager.input'
local Sync = core.import 'manager.sync'
local GSID = core.import 'manager.gsid'
local CharAttributes = require 'data.scripts.component.attributes'
local frame = require 'data.scripts.frame'
local object = require 'data.scripts.object'
local SoundSystem = core.import 'class.component.sound'
local cases = require 'data.tests.flf_unit_cases'

local Room = Scene { active = false }

	local BTN = {
		up = 1,
		down = 2,
		left = 4,
		right = 8,
		attack = 16,
		jump = 32,
		defend = 64,
	}

	local KEY = {
		att = 'attack',
		def = 'defend',
	}

	local current = nil

	local function normalizeBackground(bg)
		if type(bg) == 'string' then
			bg = Parser:parseFile(bg)
		end
		if type(bg) ~= 'table' then
			return nil
		end

		bg = helper.copyTable(bg)
		bg.borders = bg.borders or { }
		if bg.layers then
			bg.nodes = bg.nodes or { }
			for i = 1, #bg.layers do
				local layer = bg.layers[i]
				bg.nodes[#bg.nodes + 1] = {
					[1] = ('LAYER_%d'):format(i),
					_type = 'image',
					x = layer.x,
					y = layer.y,
					hparallax = layer.width / bg.width,
					sprites = { { layer[1] } },
				}
			end
			bg.layers = nil
		end
		if bg.zboundary then
			bg.borders.z1 = bg.zboundary[1]
			bg.borders.z2 = bg.zboundary[2]
			bg.zboundary = nil
		end
		if bg.width then
			bg.borders.x2 = bg.width
		end
		bg.layer = 'GAME_LAYER'
		return bg
	end

	local function createBackground()
		local bg = normalizeBackground(data.bgdata and data.bgdata:getById(1))
		if not bg and cfg.backgrounds and cfg.backgrounds[1] then
			bg = normalizeBackground(cfg.backgrounds[1].file or cfg.backgrounds[1][1])
		end
		assert(bg, 'F.LF test background is missing')
		return bg
	end

	local function createFighter(index, player, spec)
		local chardata = data.objectdata and data.objectdata:getById(spec.id)
			or data.chardata:getById(spec.id)
		assert(chardata, ('F.LF test character is missing: %s'):format(spec.id))
		chardata.playonce = chardata.playonce or cfg.playonce
		local char = Factory:create('object', chardata)
		char.data.index = index
		char.data.player = player
		char.data.team = spec.team or index
		char.data.charid = spec.id
		char.data.lf2id = spec.id
		char.data.syncid = ('flf-player:%d'):format(index)
		char.data.facing = index == 1 and 1 or -1
		char.data.x = 300 + (index - 1) * 120
		char.data.y = 0
		char.data.z = 200
		char:addComponent(Controller, player)
		char:addComponent(CharAttributes, chardata)
		return char
	end

	local function createWeapon(map, action, sequence)
		local source = data.objectdata and data.objectdata:getById(action.id)
		assert(source, ('F.LF test weapon is missing: %s'):format(action.id))
		source.playonce = source.playonce or cfg.playonce
		local obj = Factory:create('object', source)
		obj.data._lf2 = true
		obj.data._lf2_type = source._lf2_type
		obj.data.lf2id = action.id
		obj.data.team = 0
		obj.data.syncid = ('flf-weapon:%d:%d'):format(action.id, sequence)
		obj.data.x = action.x or 0
		obj.data.y = -(action.y or 0)
		obj.data.z = action.z or 0
		obj.data.facing = 1
		if not obj.C.sound then
			obj:addComponent(SoundSystem, source)
		end
		object.registerDynamic(obj)
		map:attach(obj)
		return obj
	end

	local function contains(value, expected)
		if expected == nil then
			return true
		end
		if type(expected) ~= 'table' then
			return value == expected
		end
		for i = 1, #expected do
			if value == expected[i] then
				return true
			end
		end
		return false
	end

	local function formatExpected(value)
		if type(value) ~= 'table' then
			return tostring(value)
		end
		local list = { }
		for i = 1, #value do
			list[#list + 1] = tostring(value[i])
		end
		return '{' .. table.concat(list, ',') .. '}'
	end

	local function samplePosition(obj)
		local objdata = obj.data
		local sample_y = objdata._lf2_sample_y
		return {
			x = objdata.x or 0,
			y = sample_y ~= nil and sample_y or -(objdata.y or 0),
		}
	end

	local function keyName(value)
		return KEY[value] or value
	end

	local function firstFrame(value)
		if type(value) == 'table' then
			return tonumber(value[1])
		end
		return tonumber(value)
	end

	local function addKey(mask, key)
		return mask + (BTN[keyName(key)] or 0)
	end

	local function makeMask(input, subframe)
		local mask = 0
		for key in pairs(input.long) do
			mask = addKey(mask, key)
		end
		for key in pairs(input.hold) do
			mask = addKey(mask, key)
		end
		if subframe == 0 then
			for key in pairs(input.pulse) do
				mask = addKey(mask, key)
			end
		end
		return mask
	end

	local function setButtons(player, mask)
		Input.buttons[player] = Input.buttons[player] or { }
		for key, bit in pairs(BTN) do
			Input.buttons[player][key] = mask % (bit + bit) >= bit
		end
	end

	local function primeDoubleTap(player, key)
		local bit = BTN[keyName(key)]
		if not bit or Input.frame < 3 then
			return
		end
		Input:addinput(0, player, Input.frame - 3, true)
		Input:addinput(bit, player, Input.frame - 2, true)
		Input:addinput(0, player, Input.frame - 1, true)
	end

	local function applyInputs()
		if not current then
			return
		end
		for player = 1, #current.inputs do
			local state = current.inputs[player]
			local synthetic_double = current.subframe == 0 and state.double or nil
			if current.players[player] then
				current.players[player].data._lf2_double = synthetic_double
			end
			if current.subframe == 0 and state.double then
				for key in pairs(state.double) do
					primeDoubleTap(player, key)
				end
				state.double = nil
			end
			local mask = makeMask(state, current.subframe)
			setButtons(player, mask)
			Input:addinput(mask, player, Input.frame, true)
		end
		Input:update(0, false)
	end

	local function eachInput(value, callback)
		if type(value) == 'table' then
			for i = 1, #value do
				callback(value[i])
			end
		elseif value then
			callback(value)
		end
	end

	local function prepareNextInput(logical)
		local ccase = current.case
		for player = 1, #current.inputs do
			local input = current.inputs[player]
			local step = ccase.player[player] and ccase.player[player][logical + 1]
			local pressed = { }
			input.hold = { }
			input.pulse = { }
			input.double = nil
			if step and step.k then
				local counts = { }
				eachInput(step.k, function (raw)
					local command, key = tostring(raw):match('^(%S+)%s+(.+)$')
					if command == 'hold' then
						key = keyName(key)
						input.hold[key] = true
						pressed[key] = true
					elseif command == 'longhold' then
						key = keyName(key)
						input.long[key] = true
						pressed[key] = true
					elseif command == 'release' then
						key = keyName(key)
						input.long[key] = nil
						input.hold[key] = nil
					else
						key = keyName(raw)
						input.pulse[key] = true
						pressed[key] = true
						counts[key] = (counts[key] or 0) + 1
					end
				end)
				for key, count in pairs(counts) do
					if count > 1 then
						input.double = input.double or { }
						input.double[key] = true
						if key == 'left' or key == 'right' then
							local obj = current.players[player]
							local frames = obj and obj.C.frames
							local frameid = obj and obj.data.frame and obj.data.frame.id
							if frames and frameid and frameid >= 0 and frameid <= 3 then
								obj.data.facing = key == 'left' and -1 or 1
								frame.set(obj, 'running', true)
							end
						end
					end
				end
				local obj = current.players[player]
				local frames = obj and obj.C.frames
				local objdata = obj and obj.data
				local frameid = objdata and objdata.frame and objdata.frame.id
				if frames and objdata and (frameid == 110 or frameid == 111) then
					local facing = objdata.facing or 1
					local forward = pressed[facing == 1 and 'right' or 'left']
					local back = pressed[facing == 1 and 'left' or 'right']
					local target
					if pressed.attack and pressed.jump then
						target = firstFrame(objdata.hit_ja or objdata.frame.hit_ja)
					elseif pressed.attack and pressed.up then
						target = firstFrame(objdata.hit_Ua or objdata.frame.hit_Ua)
					elseif pressed.attack and pressed.down then
						target = firstFrame(objdata.hit_Da or objdata.frame.hit_Da)
					elseif pressed.attack and forward then
						target = firstFrame(objdata.hit_Fa or objdata.frame.hit_Fa)
					elseif pressed.attack and back then
						target = firstFrame(objdata.hit_Ba or objdata.frame.hit_Ba)
					elseif pressed.jump and pressed.up then
						target = firstFrame(objdata.hit_Uj or objdata.frame.hit_Uj)
					elseif pressed.jump and pressed.down then
						target = firstFrame(objdata.hit_Dj or objdata.frame.hit_Dj)
					elseif pressed.jump and forward then
						target = firstFrame(objdata.hit_Fj or objdata.frame.hit_Fj)
					elseif pressed.jump and back then
						target = firstFrame(objdata.hit_Bj or objdata.frame.hit_Bj)
					end
					if target and target ~= 0 then
						frame.set(obj, target, true)
					end
				end
			end
		end
	end

	local function caseLabel(item)
		local index = item.index
		return ('%d.%d.%d %s'):format(index.suite, index.scenario, index.case, item.case.name)
	end

	local function matchesFilter(item, filter)
		if not filter or filter == '' then
			return true
		end
		filter = filter:lower()
		if filter:sub(1, 1) == '=' then
			local index = item.index
			local exact = filter:sub(2)
			return caseLabel(item):lower() == exact
				or ('%d.%d.%d'):format(index.suite, index.scenario, index.case) == exact
		end
		return caseLabel(item):lower():find(filter, 1, true) ~= nil
			or item.source:lower():find(filter, 1, true) ~= nil
	end

	local function collectCases(filter)
		local result = { }
		for _, suite in ipairs(cases.suites) do
			for _, scenario in ipairs(suite.scenarios) do
				for _, ccase in ipairs(scenario.cases) do
					local item = {
						source = suite.source,
						scenario = scenario,
						case = ccase,
						index = ccase.index,
					}
					if matchesFilter(item, filter) then
						result[#result + 1] = item
					end
				end
			end
		end
		return result
	end

	local function addFailure(message)
		local test = data.test
		test.flf_failures[#test.flf_failures + 1] = message
		if #test.flf_failures <= 40 then
			if test.flf_strict then
				log:error(message)
			else
				log:warn(message)
			end
		end
	end

	local function addDetail(message)
		local test = data.test
		test.flf_details[#test.flf_details + 1] = message
		if #test.flf_details <= 40 then
			log:warn(message)
		end
	end

	local function samplePlayer(player, logical)
		local ccase = current.case
		local spec = ccase.player[player] and ccase.player[player][logical + 1]
		if not spec then
			return
		end

		local char = current.players[player]
		local mem = current.mem[player]
		local stats = current.stats[player]
		local position = samplePosition(char)
		local frame = char.data.frame and char.data.frame.id or -1
		local prefix = ('FLF %s P%d T%d'):format(caseLabel(current.item), player, logical)
		if data.test.debug then
			local frames = char.C.frames
			local _, _, _, nextframe, counter = frames and frames.stats()
			log:debug('%s frame=%s next=%s counter=%s pos=(%.3f,%.3f) vel=(%.3f,%.3f) dv=(%.3f,%.3f) ground=%s',
				prefix, frame, nextframe, counter, position.x, position.y,
				char.data.vx or 0, char.data.vy or 0, char.data.dvx or 0, char.data.dvy or 0,
				tostring(char.data.ground))
		end

		if spec.f ~= nil then
			stats.has_frame = true
			if contains(frame, spec.f) then
				stats.frame_ok = stats.frame_ok + 1
			else
				stats.frame_errors = stats.frame_errors + 1
				addDetail(('%s frame expected %s got %s'):format(prefix, formatExpected(spec.f), frame))
			end
		end

		if logical == 0 then
			mem.ps = { x = 0, y = 0 }
			mem.psl = position
			mem.pso = position
			return
		end

		if not mem.psl then
			mem.ps = { x = 0, y = 0 }
			mem.psl = position
			mem.pso = position
		end
		if spec.dx ~= nil then
			local err = (position.x - mem.psl.x) - spec.dx
			stats.dx = stats.dx + math.abs(err)
			mem.ps.x = mem.ps.x + spec.dx
			if math.abs(err) > 0.001 then
				addDetail(('%s dx expected %.3f got %.3f diff %.3f'):format(prefix, spec.dx, position.x - mem.psl.x, err))
			end
		end
		if spec.dy ~= nil then
			local err = (position.y - mem.psl.y) - spec.dy
			stats.dy = stats.dy + math.abs(err)
			mem.ps.y = mem.ps.y + spec.dy
			if math.abs(err) > 0.001 then
				addDetail(('%s dy expected %.3f got %.3f diff %.3f'):format(prefix, spec.dy, position.y - mem.psl.y, err))
			end
		end
		local tx = position.x - mem.pso.x - mem.ps.x
		local ty = position.y - mem.pso.y - mem.ps.y
		stats.trajectory = stats.trajectory + math.sqrt(tx * tx + ty * ty)
		stats.trajectory_count = stats.trajectory_count + 1
		mem.psl = position
	end

	local function finishCase()
		local test = data.test
		local threshold = cases.passing_delta or 10
		for player = 1, #current.players do
			local stats = current.stats[player]
			local delta = stats.frame_errors + stats.dx + stats.dy
			test.flf_finished = test.flf_finished + 1
			test.flf_delta = test.flf_delta + delta
			if delta <= threshold then
				test.flf_passed = test.flf_passed + 1
			else
				addFailure(('FLF %s P%d delta %.3f exceeded %.3f'):format(caseLabel(current.item), player, delta, threshold))
			end
		end
	end

	local function resetCase()
		if not current then
			return
		end
		if current.map then
			Room:detach(current.map)
		end
		for i = #current.players, 1, -1 do
			current.players[i]:destroy()
			current.players[i] = nil
		end
		object.clearDynamic()
		current = nil
	end

	local function applySetup(action, sequence)
		if action.action == 'set_pos' then
			local obj = current.players[action.player]
			if obj then
				obj.data.x = action.x or obj.data.x
				obj.data.y = -(action.y or 0)
				obj.data.z = action.z or obj.data.z
				obj.data.vx, obj.data.vy, obj.data.vz = 0, 0, 0
				obj.data.dvx, obj.data.dvy, obj.data.dvz = 0, 0, 0
				obj.data.ground = obj.data.y == 0
				obj.data.facing = action.player == 1 and 1 or -1
			end
		elseif action.action == 'create_weapon' then
			createWeapon(current.map, action, sequence)
		end
	end

	local function startCase(item)
		local ccase = item.case
		local map = Factory:create('map', createBackground())
		local players = { }
		local inputs = { }
		current = {
			item = item,
			case = ccase,
			map = map,
			players = players,
			inputs = inputs,
			mem = { },
			stats = { },
			logical = -(cases.case_start_delay or 30),
			subframe = 0,
		}

		for i = 1, #item.scenario.players do
			players[i] = createFighter(i, i, item.scenario.players[i])
			map:attach(players[i])
			inputs[i] = { long = { }, hold = { }, pulse = { } }
			current.mem[i] = { }
			current.stats[i] = {
				frame_ok = 0,
				frame_errors = 0,
				dx = 0,
				dy = 0,
				trajectory = 0,
				trajectory_count = 0,
			}
		end

		for i = 1, #(ccase.setup or { }) do
			applySetup(ccase.setup[i], i)
		end

		Room:attach(map)
		log:info('FLF case %s', caseLabel(item))
	end

	local function finishAll()
		local test = data.test
		local success = #test.flf_failures == 0
		local strict = test.flf_strict
		data.test.active = false
		core.speed = 1
		if success then
			log:success('FLF TEST passed: %d/%d player-cases delta %.3f',
				test.flf_passed, test.flf_finished, test.flf_delta)
		elseif strict then
			log:error('FLF TEST failed: %d/%d player-cases passed, %d threshold failures, delta %.3f',
				test.flf_passed, test.flf_finished, #test.flf_failures, test.flf_delta)
		else
			log:warn('FLF TEST diagnostic: %d/%d player-cases passed, %d threshold failures, delta %.3f',
				test.flf_passed, test.flf_finished, #test.flf_failures, test.flf_delta)
		end
		if test.exit then
			core.api.event.quit((success or not strict) and 0 or 1)
		end
	end

	local function startNextCase()
		resetCase()
		local test = data.test
		test.flf_current = (test.flf_current or 0) + 1
		local item = test.flf_cases[test.flf_current]
		if not item then
			finishAll()
			return
		end
		startCase(item)
	end

	function Room:enter()
		log:debug 'Room: F.LF UNIT TEST'
		data.test = data.test or { }
		data.test.active = true
		data.test.mode = 'flf'
		data.test.speed = data.test.speed or 240
		data.test.flf_current = 0
		data.test.flf_finished = 0
		data.test.flf_passed = 0
		data.test.flf_delta = 0
		data.test.flf_failures = { }
		data.test.flf_details = { }
		data.test.flf_cases = collectCases(data.test.case_filter)
		core.speed = data.test.speed
		Input.delay = 0
		Input:unlock():reset(0)
		Sync:mode(Sync.NONE):reset()
		GSID:init { seed = 12564, salt = 13 }
		if #data.test.flf_cases == 0 then
			log:error('FLF TEST found no cases for filter: %s', data.test.case_filter or '')
			finishAll()
			return
		end
		log:info('FLF TEST started: %d cases', #data.test.flf_cases)
		startNextCase()
	end

	function Room:leave()
		resetCase()
	end

	function Room:preupdate()
		if data.test and data.test.flf_start_next then
			data.test.flf_start_next = nil
			startNextCase()
			return
		end
		applyInputs()
	end

	function Room:lastupdate()
		if not current then
			return
		end
		if current.subframe == 0 then
			current.subframe = 1
			return
		end

		local logical = current.logical
		if logical >= 0 and logical < current.case.duration then
			for player = 1, #current.players do
				samplePlayer(player, logical)
			end
			prepareNextInput(logical)
		end

		current.logical = logical + 1
		current.subframe = 0
		if current.logical >= current.case.duration then
			finishCase()
			data.test.flf_start_next = true
		end
	end

return Room
