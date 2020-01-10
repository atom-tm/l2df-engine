local core = l2df

local Scene = core.import 'class.entity.scene'
local Object = core.import 'class.entity.object'
local UI = core.import 'class.entity.ui'

local parser = core.import 'class.parser.lffs'
local helper = core.import 'helper'

local Controller = core.import 'class.component.controller.local'
local Physix = core.import 'class.component.physix'
local EventManager = core.import 'manager.event'
local NetworkManager = core.import 'manager.network'
local Snapshot = core.import 'manager.snapshot'
local Input = core.import 'manager.input'
local RM = core.import 'manager.resource'


local ball = Object {
	sprites = { 'sprites/test/ball.png', 50, 50, 1, 1 },
	x = 100,
	y = 200,
}
ball:createComponent(Controller, 1)

local room = Scene {
	nodes = { ball }
}

local state = 0
local data = ''

local function keypressed(_, key)
	if key == 'f12' then
		NetworkManager:destroy()
		state = 0
	elseif key == 'return' then
		if state == 0 and data ~= '' then
			state = 1
			NetworkManager:init(data)
			print('Network:', NetworkManager:username(), NetworkManager.ip)
			return
		elseif state == 1 then
			state = 2
			if not NetworkManager:isConnected() then
				NetworkManager:join(data)
				return
			end
		end
		NetworkManager:broadcast(data)
	elseif key == 'f5' then
		for obj in room:enum() do
			Snapshot:stage(obj.sync, obj, obj:sync())
		end
		Snapshot:commit()
		-- print( helper.dump(Snapshot:hist().prev[3]) )
	elseif key == 'f6' then
		Input.time = 0 -- Snapshot:rollback(0)
	elseif key == 'backspace' then
		data = ''
	elseif key == 'f7' then
		print(RM:loadListAsync({
			"sprites/test/1.png",
			"sprites/test/2.png",
			"sprites/test/3.png",
			"sprites/test/5.png",
			"sprites/test/ball.png",
		}))
	elseif state < 2 then
		-- data = data .. key
		-- print(data)
	end
end

NetworkManager:register('127.0.0.1:12565')
EventManager:subscribe('keypressed', keypressed)

return room