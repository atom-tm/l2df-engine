local core = assert(l2df, 'L2DF is not available')
local data = assert(data, 'Shared data is not available')

-- UTILS
local log = core.import 'class.logger'
local json = core.import 'class.parser.json'

-- MANAGERS
local Input = core.import 'manager.input'
local Factory = core.import 'manager.factory'
local SceneManager = core.import 'manager.scene'
local EventManager = core.import 'manager.event'
local Network = core.import 'manager.network'
local Recorder = core.import 'manager.recorder'
local Sync = core.import 'manager.sync'
local GSID = core.import 'manager.gsid'

local Room, RoomMap = data.layout('layout/battle.dat')

	local objects = { }
	local DesyncNode = Room.R.DESYNC()
	local LoadingNode = Room.R.LOADING()
	local FrameCounter = Room.R.FRAME_COUNTER()
	local resetMatch
	local stopReplayRecording

	local function flag(value)
		return value and 1 or 0
	end

	local function fastTestHash(hash, index, obj)
		local objdata = obj.data or { }
		local frame = objdata.frame or { }
		hash(
			'obj:', index, ':', objdata.syncid or objdata.index or objdata.player or obj.key or index, ':',
			flag(obj.active), ':',
			objdata.player or 0, ':', objdata.team or 0, ':',
			frame.id or 0, ':', frame.keyword or '', ':', objdata.next or 0, ':', objdata.wait or 0, ':',
			objdata.x or 0, ':', objdata.y or 0, ':', objdata.z or 0, ':',
			objdata.vx or 0, ':', objdata.vy or 0, ':', objdata.vz or 0, ':',
			objdata.dvx or 0, ':', objdata.dvy or 0, ':', objdata.dvz or 0, ':',
			objdata.facing or 0, ':', flag(objdata.ground), ':', flag(objdata.isjumped), ':',
			flag(objdata.isdashed), ':', objdata.flip or 0, ':', objdata.pic or 0, ';'
		)
		local attr = obj.C and obj.C.attr
		local adata = attr and attr.data and attr.data() or nil
		if adata then
			hash(
				'attr:', adata.hp or 0, ':', adata.defence or 0, ':',
				flag(adata.candefend), ':', flag(adata.cansuper), ';'
			)
		end
	end

	local function finishTestMode(success, failures)
		local test = data.test
		if test then
			test.active = false
		end
		if stopReplayRecording then
			stopReplayRecording()
		end
		core.speed = 1
		if success then
			log:success('TEST passed: %d frames verified', test and test.frames or 0)
		else
			log:error('TEST failed: %d mismatches', #failures)
		end
		if test and test.exit then
			core.api.event.quit(success and 0 or 1)
		else
			resetMatch()
		end
	end

	local function setupTestMode()
		local test = data.test
		if not (test and test.active) then return end
		test.frames = test.frames or 240
		Sync:test {
			frames = test.frames,
			players = test.players or 2,
			input = test.input,
			rollbacks = test.rollbacks,
			debug = test.debug,
			hash = test.hash,
			fasthash = fastTestHash,
			onfinish = finishTestMode,
		}
	end

	EventManager:subscribe('keypressed', function (key)
		if key ~= 'f1' then return end
		if not Network:isConnected() then
			Room.timer = 0
			return
		end
		local delay = 0
		for _, c in Network:clients() do
			delay = math.max(delay, c:ping())
		end
		Room.isTimerActive = true
		Room.timer = delay * 0.0005
		Network:broadcast('netstop', delay)
		log:info('[L] Game ends in %fs', Room.timer)
	end)

	Network:event('netstop', 'H', function (c, e, delay)
		Room.isTimerActive = true
		Room.timer = (delay - c:ping()) * 0.0005
		log:info('[R] Game ends in %fs', Room.timer)
	end)

	-- Rollback code
	local function makeSnapshot()
		-- IMPORTANT: SAVE GSID HERE
		Sync:stage(GSID.sync, GSID.sync())
		local hash = Sync:hash()
		local index = 0
		for obj in RoomMap:enum() do
			index = index + 1
			Sync:stage(obj.sync, obj, obj:sync())
			if data.test and data.test.active then
				obj.data.syncid = obj.data.syncid or ('obj:%d'):format(index)
			end
			if not Sync:testobject(hash, index, obj) then
				hash(obj.data.next or 0, obj.data.x, obj.data.y, obj.data.z)
			end
		end
		return Sync:testhash(hash)
	end

	local function safeReplayName(name)
		return tostring(name or 'player'):gsub('[^%w%._%-]', '_')
	end

	local function replayPathExists(path)
		local file = io.open(path, 'rb')
		if file then
			file:close()
			return true
		end
		return false
	end

	local function replaySalt()
		if love and love.math and love.math.random then
			return string.format('%08X', love.math.random(0, 0x7FFFFFFF))
		end
		return string.format('%08X', math.random(0, 0x7FFFFFFF))
	end

	local function makeReplayMetadata()
		local replay = data.replay or { }
		local players = { }
		for i = 1, #objects do
			local objdata = objects[i].data or { }
			players[i] = {
				index = objdata.index or i,
				player = objdata.player or i,
				team = objdata.team or 0,
				char = objdata.charid or objects[i].charid or i,
				x = objdata.x or 0,
				y = objdata.y or 0,
				z = objdata.z or 0,
				facing = objdata.facing or 1,
				syncid = objdata.syncid,
			}
		end
		return {
			version = 1,
			preset = 'lf2',
			fps = data.FPS,
			background = replay.background or 1,
			players = players,
		}
	end

	local function replayPath()
		core.api.io.mkdir('replays')
		local timestamp = os.date('%Y%m%d-%H%M%S')
		local folder = core.savepath('replays')
		local filename = string.format('%s-%s-%s',
			safeReplayName(data.players and data.players[1]),
			timestamp,
			replaySalt()
		)
		local path = string.format('%s/%s.replay', folder, filename)
		local suffix = 1
		while replayPathExists(path) do
			path = string.format('%s/%s-%d.replay', folder, filename, suffix)
			suffix = suffix + 1
		end
		return path
	end

	local function shouldRecordReplay()
		local replay = data.replay or { }
		if replay.playing or replay.record == false then
			return false
		end
		return true
	end

	local function startReplayRecording()
		if not shouldRecordReplay() then return end
		local replay = data.replay or { }
		data.replay = replay
		replay.current = replayPath()
		replay.metadata = makeReplayMetadata()
		Recorder:start(replay.current, json:dump(replay.metadata, true), nil, 1)
		log:info('Recording replay to %s', replay.current)
	end

	function stopReplayRecording()
		local replay = data.replay
		if not (replay and replay.current) then return end
		if replay.metadata then
			replay.metadata.frames = Sync.frame
			Recorder:metadata(replay.current, json:dump(replay.metadata, true))
			replay.metadata = nil
		end
		Recorder:stop(replay.current)
		log:info('Replay saved to %s', replay.current)
		replay.current = nil
	end

	local function startMatch()
		local replay = data.replay or { }
		math.randomseed(12564)
		GSID:init { seed = 12564, salt = 3 }
		Sync:mode(Sync.ROLLBACK):reset().persist(makeSnapshot)
		if replay.playing then
			Input:lock():reset(Input.remoteplayers, 0, true)
		else
			Input:unlock():reset(Input.remoteplayers)
		end
		setupTestMode()
		Room:attach(RoomMap)
		LoadingNode.active = false
		data.isplaying = true
		startReplayRecording()
		log:success('Match has been started')
	end

	function resetMatch()
		stopReplayRecording()
		data.isplaying = false
		SceneManager:pop()
		Room:detach(RoomMap)
		for i = #objects, 1, -1 do
			objects[i]:destroy()
			objects[i] = nil
		end
	end

	function Room:enter(map, chars)
		log:debug 'Room: BATTLE'
		if not (map and chars) then
			return log:warn('Entered battle w/o map and characters')
		end
		self.isTimerActive = false
		self.timer = 3
		RoomMap = map
		LoadingNode.active = true
		math.randomseed(12564)
		GSID:init { seed = 12564, salt = 3 }
		local test = data.test
		local testActive = test and test.active
		local replayActive = data.replay and data.replay.playing
		for i = 1, #chars do
			chars[i].data.syncid = chars[i].data.syncid or ('player:%d'):format(i)
			if not replayActive then
				local spawn = testActive and test.spawns and test.spawns[i]
				chars[i].data.x = spawn and spawn.x or data.random(200, 700)
				chars[i].data.y = 0
				chars[i].data.z = spawn and spawn.z or 0
				chars[i].data.facing = spawn and spawn.facing or chars[i].data.facing
			end
			RoomMap:attach(chars[i])
		end
		objects = chars
		if replayActive or Input.remoteplayers == 0 or testActive then
			startMatch()
		else
			data.ready = true
			data.ontimer = startMatch
			Network:broadcast('netready')
		end
	end

	function Room:filedropped(file)
		local path = file and file:getFilename()
		if not (path and path:match('%.replay$')) then return end
		resetMatch()
		data.openReplay(path)
	end

	function Room:preupdate(dt)
		DesyncNode.active = Sync.desync
		local ping = 0
		if Input.remoteplayers > 0 then
			for _, c in Network:clients() do
				ping = math.max(ping, c:ping())
			end
		end
		FrameCounter.data.text = string.format('%05d : %d : %d', Sync.frame, core.api.time.fps(), ping)
	end

	function Room:update(dt)
		if Sync:testupdate() then
			return
		end
		local replay = data.replay
		if replay and replay.playing and replay.frames and Sync.frame >= replay.frames then
			resetMatch()
			return
		end
		local lastAlive = nil
		for i = 1, #objects do
			local team = objects[i].data.team or 0
			local attr = objects[i].C.attr
			if attr and attr.data().hp > 0 then
				if lastAlive and (lastAlive ~= team or lastAlive + team == 0) then
					lastAlive = nil
					break
				end
				lastAlive = team
			end
		end
		if #objects > 1 and lastAlive then
			self.isTimerActive = true
		end
		if self.isTimerActive then
			self.timer = self.timer - dt
		end
		if self.timer <= 0 then
			resetMatch()
		end
	end

return Room
