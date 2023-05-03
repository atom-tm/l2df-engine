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
local Factory = l2df.import 'manager.factory'
local SceneManager = core.import 'manager.scene'
local RenderManager = core.import 'manager.render'
local Network = core.import 'manager.network'
local Sync = core.import 'manager.sync'

local Room = data.layout('layout/battle.dat')

	function Room:enter(chars)
		log:debug 'Room: BATTLE'
		if not chars then return end
		local bg = data.bgdata:getById(1); bg.layer = 'GAME_LAYER'
		local map = Factory:create('map', bg)
		for i = 1, #chars do
			chars[i].data.x = data.random(200, 700)
			map:attach(chars[i])
		end
		self:attach(map)
	end

return Room