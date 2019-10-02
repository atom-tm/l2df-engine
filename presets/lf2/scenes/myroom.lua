local core = l2df
local Scene = core.import 'core.class.entity.scene'
local UI = core.import 'core.class.entity.ui'
local parser = core.import 'parsers.lffs'

local Physix = core.import 'core.class.component.physix'
local EventManager = core.import 'core.manager.event'
local NetworkManager = core.import 'core.manager.network'

local Object = core.import 'core.class.entity.object'

local ball = Object {
	sprites = 'sprites/test/ball.png',
	x = 250,
	y = 250,
}
ball.vars.centerX = 25
ball.vars.centerY = 25

local room = Scene {
	nodes = {
		ball
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
		data = string.char(0)
		print(data)
	elseif key == 'backspace' then
		data = ''
	-- elseif key == 'w' then
	-- 	ball.vars.dvy = -4
	-- elseif key == 's' then
	-- 	ball.vars.dvy = 4
	elseif key == 'f2' then
		ball:getComponent(Physix).gravity = not ball:getComponent(Physix).gravity
	elseif key == 'f1' then
		ball:getComponent(Physix).platform = Physix:new({ bounce = 0.5 })
	else
		data = data .. key
		print(data)
	end
end

NetworkManager:register('127.0.0.1:12565')

EventManager:subscribe('update', NetworkManager.update, nil, NetworkManager)
EventManager:subscribe('keypressed', f)

return room