local core = l2df

local Scene = core.import 'class.entity.scene'
local Object = core.import 'class.entity.object'
local UI = core.import 'class.entity.ui'

local parser = core.import 'class.parser.lffs'
local helper = core.import 'helper'

local Physix = core.import 'class.component.physix'
local Input = core.import 'manager.input'
local EventManager = core.import 'manager.event'
local SceneManager = core.import 'manager.scene'
local NetworkManager = core.import 'manager.network'
local Snapshot = core.import 'manager.snapshot'
local RM = core.import 'manager.resource'


local ball = Object {
	sprites = { 'sprites/test/ball.png', 50, 50, 1, 1 },
	x = 100,
	y = 200,
}

local wall = Object {
	sprites = { 'sprites/test/5.png' },
	x = 100,
	y = 200,
}

local wall2 = Object {
	sprites = { 'sprites/test/5.png' },
	x = 550,
	y = 200,
}

local room = Scene {
	nodes = {
		ball,
		--wall,
		--wall2
	}
}

local state = 0
local data = ''
local f = function (_, key)
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
		for obj in SceneManager.root:enum() do
			Snapshot:stage(obj.sync, obj, obj:sync())
		end
		Snapshot:commit()
		-- print( helper.dump(Snapshot:hist().prev[3]) )
	elseif key == 'f6' then
		Snapshot:rollback(0)
	elseif key == 'backspace' then
		data = ''
	elseif key == 'up' then
		ball.vars.dvy = -64
	elseif key == 'down' then
		ball.vars.dvy = 64
	elseif key == 'left' then
		ball.vars.dvx = -64
	elseif key == 'right' then
		ball.vars.dvx = 64
	elseif key == 'f2' then
		ball:getComponent(Physix).gravity = not ball:getComponent(Physix).gravity
	elseif key == 'f1' then
		ball:getComponent(Physix).platform = Physix:new({ bounce = 0.5 })
	elseif key == 'f7' then
		print(RM:loadListAsync({
			"sprites/test/1.png",
			"sprites/test/2.png",
			"sprites/test/3.png",
			"sprites/test/5.png",
			"sprites/test/ball.png",
		}))
	else
		data = data .. key
		print(data)
	end
end

NetworkManager:register('127.0.0.1:12565')

EventManager:subscribe('keypressed', f)

return room