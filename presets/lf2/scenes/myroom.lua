local core = l2df

local Scene = core.import 'class.entity.scene'
local Object = core.import 'class.entity.object'
local UI = core.import 'class.entity.ui'

local log = core.import 'class.logger'
local parser = core.import 'class.parser.lffs'
local helper = core.import 'helper'

local LocalController = core.import 'class.component.controller.local'
local RemoteController = core.import 'class.component.controller.remote'
local Physix = core.import 'class.component.physix'
local Print = core.import 'class.component.print'

local EventManager = core.import 'manager.event'
local NetworkManager = core.import 'manager.network'
local Snapshot = core.import 'manager.snapshot'
local Input = core.import 'manager.input'
local RM = core.import 'manager.resource'

local title = UI.Text {
	text = 'Enter username and press Enter',
	font = 24
}
local titleC = title:getComponent(Print)

local ballData = {
	sprites = { 'sprites/test/ball.png', 50, 50, 1, 1 },
	states = { { 'MoveBoyMove' } },
	x = 100, y = 100,
}

local room = Scene { nodes = { title } }

local timer = 0
local delay = 0
local state = 0
local data = ''

local function save()
	for obj in room:enum() do
		Snapshot:stage(obj.sync, obj, obj:sync())
	end
	Snapshot:commit()
end

	ball = Object(ballData)
	ball:createComponent(LocalController, 1)
	room:attach(ball)

NetworkManager:register('127.0.0.1:12565')
NetworkManager:event('start', nil, function (c, e)
	delay = 3 - c:ping() / 1000
	state = 3
	NetworkManager:logout()
end)
NetworkManager:event('chat', 's', function (c, e, message)
	print(c.name, ':', message)
end)

EventManager:subscribe('update', function (_, dt)
	if delay > 0 then
		delay = delay - dt
		if delay > 0 then
			titleC.text = string.format('Game starts in %.1fs', delay)
		else
			Input:reset()
			Snapshot:reset()
			local ball = Object(ballData)
			ball:createComponent(LocalController, 1)
			room:attach(ball)
			for client in NetworkManager:clients() do
				client.player = Input:newRemotePlayer()
				ball = Object(ballData)
				ball:createComponent(RemoteController, client.player)
				room:attach(ball)
			end
			delay = 0
			titleC.text = ''
			save()
		end
	elseif state == 3 then
		titleC.text = string.format('Time: %.2fs', Input.time)
		timer = timer + dt
		if timer > 1 / 20 then
			timer = timer - 1 / 20
			save()
		end
	end
end)

EventManager:subscribe('keypressed', function (_, key)
	if key == 'f9' then
		NetworkManager:destroy()
		titleC.text = 'Enter username and press Enter'
		state = 0
		delay = 0
	elseif key == 'return' and data ~= '' then
		if state == 0 then
			state = 1
			NetworkManager:init(data)
			NetworkManager:login()
			titleC.text = NetworkManager:username()
			log:info('Username: %s', NetworkManager:username())
			data = ''
			return
		elseif state == 1 then
			state = 2
			if not NetworkManager:isConnected() then
				log:info('Searching: %s', data)
				NetworkManager:join(data)
				data = ''
				return
			end
		end
		NetworkManager:broadcast('chat', data)
	elseif key == 'f5' then
		local ping = 0
		for client in NetworkManager:clients() do
			ping = math.max(ping, client:ping() / 1000)
		end
		if NetworkManager:broadcast('start') then
			delay = 3 - ping
			state = 3
			NetworkManager:logout()
		end
	elseif key == 'backspace' then
		data = ''
	elseif key == 'f7' then
		print(RM:loadListAsync({
			'sprites/test/1.png',
			'sprites/test/2.png',
			'sprites/test/3.png',
			'sprites/test/5.png',
			'sprites/test/ball.png',
		}))
	elseif state < 3 then
		data = data .. key
		print(data)
	end
end)

return room