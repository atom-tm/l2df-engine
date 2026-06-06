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
local SceneManager = core.import 'manager.scene'
local CharAttributes = require 'data.scripts.component.attributes'

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

	local DEFAULT_ROLLBACKS = {
		{ frame = 34, target = 6 },
		{ frame = 57, target = 21 },
		{ frame = 83, target = 42 },
		{ frame = 111, target = 65 },
		{ frame = 143, target = 92 },
		{ frame = 178, target = 120 },
		{ frame = 216, target = 160 },
		{ frame = 253, target = 199 },
		{ frame = 291, target = 236 },
		{ frame = 334, target = 279 },
		{ frame = 382, target = 324 },
	}

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
		return bg
	end

	local function createBackground()
		local bg = normalizeBackground(data.bgdata and data.bgdata:getById(1))
		if not bg and cfg.backgrounds and cfg.backgrounds[1] then
			bg = normalizeBackground(cfg.backgrounds[1].file or cfg.backgrounds[1][1])
		end
		assert(bg, 'Test background is missing')
		bg.layer = 'GAME_LAYER'
		return bg
	end

	local function createFighter(index, player, charid)
		local chardata = data.chardata:getById(charid)
			or data.objectdata and data.objectdata:getById(charid)
		assert(chardata, 'Test character is missing')
		chardata.playonce = chardata.playonce or cfg.playonce
		local char = Factory:create('object', chardata)
		char.data.index = index
		char.data.player = player
		char.data.team = index
		char.data.syncid = ('test-player:%d'):format(index)
		char.data.facing = index == 1 and 1 or -1
		char:addComponent(Controller, player)
		char:addComponent(CharAttributes, chardata)
		return char
	end

	local function input(...)
		local value = 0
		for i = 1, select('#', ...) do
			value = value + (BTN[select(i, ...)] or 0)
		end
		return value
	end

	local function once(frame, ...)
		local set = { ... }
		for i = 1, #set do
			if frame == set[i] then
				return true
			end
		end
		return false
	end

	local function alternate(frame, first, second, period)
		return frame % (period * 2) < period and first or second
	end

	local function jitter(player, frame)
		local n = (frame * 1103515245 + player * 12345 + 0x3C6EF35F) % 2147483648
		return n % 97
	end

	local function pressureInput(player, frame)
		if frame == 0 then
			return 0
		elseif frame <= 12 then
			return input(player == 1 and 'right' or 'left')
		elseif frame <= 24 then
			return once(frame, 14, 19, 24) and input('attack') or 0
		elseif frame <= 36 then
			if player == 1 then
				return frame < 29 and input('defend') or input('left', 'defend')
			end
			return once(frame, 28, 33) and input('attack') or input('right')
		elseif frame <= 54 then
			local z = alternate(frame, 'up', 'down', 4)
			local x = player == 1 and 'right' or 'left'
			return once(frame, 42, 50) and input(x, z, 'attack') or input(x, z)
		end
	end

	local function runInput(player, frame)
		local dir = player == 1 and 'right' or 'left'
		local away = player == 1 and 'left' or 'right'
		local localFrame = frame - 37
		if once(localFrame, 2, 5, 26, 29) then
			return input(dir)
		elseif localFrame > 5 and localFrame < 22 then
			return input(dir, alternate(frame, 'up', 'down', 6))
		elseif once(localFrame, 22, 42) then
			return input('attack')
		elseif localFrame > 29 and localFrame < 41 then
			return input(dir)
		elseif once(localFrame, 42) then
			return input('defend')
		elseif localFrame > 48 and localFrame < 60 then
			return input(away, alternate(frame, 'up', 'down', 5))
		end
	end

	local function airInput(player, frame)
		local dir = player == 1 and 'right' or 'left'
		local away = player == 1 and 'left' or 'right'
		local localFrame = frame - 97
		if once(localFrame, 2, 24, 46) then
			return input('jump', dir)
		elseif localFrame > 2 and localFrame < 18 then
			return once(localFrame, 8, 13) and input(dir, 'attack') or input(dir)
		elseif once(localFrame, 18, 38, 58) then
			return input('jump', away)
		elseif localFrame > 24 and localFrame < 36 then
			return once(localFrame, 30, 34) and input(away, 'attack') or input(away)
		elseif localFrame > 46 and localFrame < 66 then
			return input(dir, alternate(frame, 'up', 'down', 3), localFrame % 7 == 0 and 'attack' or nil)
		end
	end

	local function chaosInput(player, frame)
		local roll = jitter(player, frame)
		local dir = roll % 4 < 2 and (player == 1 and 'right' or 'left') or (player == 1 and 'left' or 'right')
		local z = roll % 6 < 2 and 'up' or roll % 6 < 4 and 'down' or nil
		local action = nil
		if roll % 23 == 0 or frame % (player == 1 and 37 or 41) == 0 then
			action = 'jump'
		elseif roll % 17 == 0 or frame % (player == 1 and 29 or 31) == 0 then
			action = 'attack'
		elseif roll % 19 == 0 or frame % (player == 1 and 43 or 47) == 0 then
			action = 'defend'
		end
		if frame % 53 == player * 3 then
			return input(dir)
		elseif frame % 53 == player * 3 + 2 then
			return input(dir)
		end
		return input(dir, z, action)
	end

	local function specialInput(player, frame)
		local dir = player == 1 and 'right' or 'left'
		local localFrame = frame - (frame < 30 and 6 or 66)
		if localFrame < 0 or localFrame > 18 then
			return nil
		end
		if once(localFrame, 6, 10, 14) then
			return input('defend', dir, 'attack')
		end
		return input('defend', dir)
	end

	local function testInput(player, frame)
		local test = data.test
		local script = test and test.script
		if script and script[player] and script[player][frame] then
			return script[player][frame]
		end
		return specialInput(player, frame)
			or pressureInput(player, frame)
			or runInput(player, frame)
			or airInput(player, frame)
			or chaosInput(player, frame)
	end

	function Room:enter()
		log:debug 'Room: TEST'
		data.test = data.test or { }
		data.test.active = true
		data.test.speed = data.test.speed or 60
		data.test.input = data.test.input or testInput
		data.test.rollbacks = data.test.rollbacks or DEFAULT_ROLLBACKS
		data.test.spawns = data.test.spawns or {
			{ x = 330, z = 424, facing = 1 },
			{ x = 438, z = 436, facing = -1 },
		}
		core.speed = data.test.speed
		Input.delay = 0
		Input:lock():reset(0)

		local testChars = data.test.chars or { }
		local chars = {
			createFighter(1, 1, testChars[1] or 1),
			createFighter(2, 2, testChars[2] or (data.chardata.count >= 2 and 2 or 1)),
		}
		SceneManager:push('battle', Factory:create('map', createBackground()), chars)
	end

return Room
