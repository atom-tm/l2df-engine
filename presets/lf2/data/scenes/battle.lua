local core = assert(l2df, 'L2DF is not available')
local data = assert(data, 'Shared data is not available')

-- UTILS
local log = core.import 'class.logger'
local cfg = core.import 'config'

-- COMPONENTS
local States = core.import 'class.component.states'
local Frames = core.import 'class.component.frames'
local Collision = core.import 'class.component.collision'

-- MANAGERS
local Input = core.import 'manager.input'
local Factory = core.import 'manager.factory'
local SceneManager = core.import 'manager.scene'
local RenderManager = core.import 'manager.render'
local Network = core.import 'manager.network'
local Sync = core.import 'manager.sync'
local GSID = core.import 'manager.gsid'

local Room, RoomMap = data.layout('layout/battle.dat')

	local objects = { }
	local DesyncNode = Room.R.DESYNC()
	local LoadingNode = Room.R.LOADING()
	local FrameCounter = Room.R.FRAME_COUNTER()

	-- Rollback code
	local function makeSnapshot()
		-- IMPORTANT: SAVE GSID HERE
		Sync:stage(GSID.sync, GSID.sync())
		local hash = Sync:hash()
		for obj in RoomMap:enum() do
			Sync:stage(obj.sync, obj, obj:sync())
			hash(obj.data.next or 0, obj.data.x, obj.data.y, obj.data.z)
		end
		return hash()
	end

	local function startMatch()
		math.randomseed(12564)
		GSID:init { seed = 12564, salt = 3 }
		Sync:mode(Sync.ROLLBACK):reset().persist(makeSnapshot)
		Input:unlock():reset(Input.remoteplayers)
		Room:attach(RoomMap)
		LoadingNode.active = false
		data.isplaying = true
		log:success('Match has been started')
	end

	function Room:enter(map, chars)
		log:debug 'Room: BATTLE'
		if not (map and chars) then
			return log:warn('Entered battle w/o map and characters')
		end
		RoomMap = map
		LoadingNode.active = true
		math.randomseed(12564)
		GSID:init { seed = 12564, salt = 3 }
		for i = 1, #chars do
			chars[i].data.x = data.random(200, 700)
			chars[i].data.y = 0
			chars[i].data.z = 0
			RoomMap:attach(chars[i])
		end
		objects = chars
		if Input.remoteplayers == 0 then
			startMatch()
		else
			data.ready = true
			data.ontimer = startMatch
			Network:broadcast('netready')
		end
	end

	function Room:preupdate(dt)
		DesyncNode.active = Sync.desync
		local ping = 0
		if Input.remoteplayers > 0 then
			for _, c in Network:clients() do
				ping = math.max(ping, c:ping())
			end
		end
		FrameCounter.data.text = string.format('%05d : %d : %d', Sync.frame, love.timer.getFPS(), ping)
	end

return Room