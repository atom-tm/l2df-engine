local core = assert(l2df, 'L2DF is not available')
local data = assert(data, 'Shared data is not available')

-- UTILS
local log = core.import 'class.logger'
local cfg = core.import 'config'

-- COMPONENTS
local States = core.import 'class.component.states'
local Collision = core.import 'class.component.collision'

-- MANAGERS
local SceneManager = core.import 'manager.scene'
local Input = core.import 'manager.input'
local Network = core.import 'manager.network'
local Sync = core.import 'manager.sync'

-- VARIABLES
local function dummyFunc() end
local function enableNode(self) self.node.active = true end
local function disableNode(self) self.node.active = false end
local function defaultAction(self, action, ...) (self.node[action] or dummyFunc)(self.node, ...) end

local Room = data.layout('layout/menu/main.dat')

	local scenes = {
		controls_menu = data.layout('layout/menu/controls.dat'),
		network_menu = data.layout('layout/menu/network.dat'),
		game_menu = data.layout('layout/menu/game.dat')
	}
	for name, scene in pairs(scenes) do
		SceneManager:add(scene, name)
	end

	local function randomBackground()
		Room.R.BG_IMAGE.data.pic = math.random(1, 13)
	end

	local function wrapButton(btn)
		if btn.name ~= 'button' then return end
		btn.nodes:first():addComponent(Collision)
		btn:onChange(function (btn)
			if btn.data.state == 1 then
				btn.nodes:first().C.frames.set('idle')
			elseif btn.data.state == 2 or btn.data.state == 3 then
				btn.nodes:first().C.frames.set('hover')
			elseif btn.data.state == 4 then
				btn.nodes:first().C.frames.set('click')
			end
		end)
	end

	-- BUTTON BINDINGS
	local Menu = Room.R.MAINMENU()
	local GMenu = scenes.game_menu
	local Multiplayer = scenes.network_menu
	local Controls = scenes.controls_menu
	Menu.R.BTN_GAME_START:onClick(function () SceneManager:push('game_menu') end)
	Menu.R.BTN_NETWORK_GAME:onClick(function () SceneManager:push('network_menu') end)
	Menu.R.BTN_CONTROL_SETTINGS:onClick(function () SceneManager:push('controls_menu') end)
	Controls.R.CONTROLS.BTN_CANCEL:onClick(function () SceneManager:pop() end)
	Multiplayer.R.BTN_CANCEL:onClick(function () SceneManager:pop() end)
	GMenu.R.MENU.BTN_VS_MODE:onClick(function () SceneManager:push('lobby') end)
	GMenu.R.MENU.BTN_QUIT:onClick(core.api.event.quit)

	wrapButton(Multiplayer.R.BTN_CANCEL())
	for _, btn in Menu.nodes:enum(true) do
		wrapButton(btn)
	end
	for _, btn in GMenu.R.MENU.nodes:enum(true) do
		wrapButton(btn)
	end
	for _, btn in Controls.R.CONTROLS.nodes:enum(true) do
		wrapButton(btn)
	end

	function Room:enter()
		log:debug 'Room: MENU'
		randomBackground()
	end

	function Room:enable()
		randomBackground()
		Menu.active = true
	end

	function Room:disable()
		Menu.active = false
	end

	function Multiplayer:enter()
		self.data.hidden = false
		self:setWait(false)
		self.lobby = dummyFunc
		Network:login(data.username)
	end

	function Multiplayer:leave()
		self:setWait(false)
		Network:logout()
	end

	function Multiplayer:start()
		Input:reset(Input.remoteplayers)
		Sync:reset()
		for _, event in ipairs { 'netupdate' } do
			self:subscribe(event, self[event], nil, self)
		end
		self.confirmed = { }
		self.inputs = { }
		self.frames = { }
		self.buffer = { }
		self.inputStream = Input:stream(1)
		self.R.BACKGROUND().active = false
		self.R.BTN_CANCEL().active = false
		SceneManager:push('game_menu')
	end

	function Multiplayer:netupdate()
		local size = #self.inputs
		local old = size
		local chksum = 0
		local s = { }
		for _, frame, input, hash in self.inputStream do
			size = size + 1
			self.inputs[size] = input
			self.frames[size] = frame
			self.buffer[size] = string.format('[%02d][%05d][%08X]', input, frame, hash)
			chksum = hash
		end
		if old ~= size then
			log:info('SENT %s', table.concat(self.buffer, ' '))
			Network:broadcast('netinput', self.inputs, self.frames, chksum, Sync.time)
		end
	end

	function Multiplayer:setWait(status)
		self.R.BACKGROUND.data.pic = status and 2 or 1
		self.R.BTN_CANCEL().active = not not status
	end

	function Multiplayer:update()
		if SceneManager:current() ~= self then return end
		if Network.lobbyid ~= nil then return end
		local lobby = self.lobby()
		if lobby then
			if #lobby > 0 then
				Network:join(lobby[1].id)
			else
				Network:host()
				self:setWait(true)
			end
			self.lobby = dummyFunc
		end
	end

	function GMenu:enable()
		Room.active = true
		self.active = true
	end

	function GMenu:disable()
		Room.active = false
		self.active = false
	end

	function GMenu:update()
		if SceneManager:current() ~= self then return end
		if Input:consume('up') then
			GMenu.R.MENU:prev()
			GMenu.R.MENU().timer = nil
			GMenu.R.CONTROL.active = false
		end
		if Input:consume('down') then
			GMenu.R.MENU:next()
			GMenu.R.MENU().timer = nil
			GMenu.R.CONTROL.active = false
		end
		if Input:consume('attack') or Input:consume('select') then
			GMenu.R.MENU:choice()
		end
		-- if Input:consume('jump') and self.SM.data().size > 1 and not self.SM.has(Username) then
		-- 	self.SM.pop()
		-- end
	end

	function Controls:enter()
		Room.R.LOGOTYPE.data.y = 35
	end

	function Controls:leave()
		Room.R.LOGOTYPE.data.y = 95
	end

	function Controls:update()
		if SceneManager:current() ~= self then return end
	end

	--- NETWORKING
	Network:register(cfg.master or '127.0.0.1:12565')
	Network:event('masterconnected', nil, function (c, e)
		if SceneManager:current() == Multiplayer and Multiplayer.lobby == dummyFunc then
			Multiplayer.lobby = Network:list(1, true)
		end
	end)
	Network:event('connected', nil, function (c, e)
		c.player = c.player or Input:newRemotePlayer()
	end)
	Network:event('verified', nil, function (c, e)
		-- local client = Network:clients('local')
		-- if client and client.charid then
		-- 	c:send('spawn', client.charid, client.spawnx, client.spawny)
		-- end
		Multiplayer:start()
		print('System', 'connected', c.name)
	end)
	-- Network:event('spawn', 'bHH', function (c, e, id, x, y)
	-- 	local char = spawnChar(id, x, y)
	-- 	Room.SM.invoke('spawn', char, c.player)
	-- 	wrapChar(char, c)
	-- end)
	-- Network:event('despawn', nil, function (c, e)
	-- 	if c.obj then
	-- 		Room.SM.invoke('despawn', c.obj, c.player)
	-- 		c.obj = nil
	-- 	end
	-- end)
	Network:event('disconnected', nil, function (c, e)
		-- if c.obj then
		-- 	Room.SM.invoke('despawn', c.obj, c.player or 10000)
		-- 	c.obj = nil
		-- end
		print('System', 'disconnected', c.name or tostring(c.peer))
	end)
	Network:event('fps', 'H', function (c, e, fps)
		c.fps = fps
	end)
	Network:event('chat', 's', function (c, e, message)
		print(c.name, message)
	end)
	-- Network:event('ready', nil, function (c, e)
	-- 	if c.obj then
	-- 		c.obj.ready = true
	-- 		log:info('Player %s[%s] is READY', c.name, c.player)
	-- 	end
	-- end)
	-- Network:event('gameready', nil, function (c, e)
	-- 	Room.SM.invoke('gameready', c:ping() * 0.0005)
	-- end)
	Network:event('netconfirm', 'I', function (c, e, frame)
		Multiplayer.confirmed[c.player] = math.max(Multiplayer.confirmed[c.player] or 0, frame)
		local min = frame
		for _, v in pairs(Multiplayer.confirmed) do
			if v < min then
				min = v
			end
		end
		local start = #Multiplayer.frames
		for i = 1, start do
			if Multiplayer.frames[i] > min then
				start = i - 1
				break
			end
		end
		if start == 0 then return end
		for i = 1, #Multiplayer.inputs do
			Multiplayer.inputs[i] = Multiplayer.inputs[start + i]
			Multiplayer.frames[i] = Multiplayer.frames[start + i]
			Multiplayer.buffer[i] = Multiplayer.buffer[start + i]
		end
	end)
	Network:event('netinput', 'AIAIId', function (c, e, input, frame, chksum, time)
		if c.player then
			Sync:updateAdvantage(time + c:ping() * 0.0005)
			local item = nil
			local s = { }
			for i = 1, #input do
				_, item = Input:addinput(input[i], c.player, frame[i])
				s[i] = string.format('[%02d][%05d][%08X]', input[i], frame[i], item.hash)
			end
			log:info('RECV[%10s] %s', c.name:match('^(%w+)#'), table.concat(s, ' '))
			if item.hash == chksum then
				c:send('netconfirm', item.frame)
			else
				Sync.desync = true
				log:error('Desync InputSize: %d Remote: %08X Local: %08X', #input, chksum, item.hash)
			end
		end
	end)

return Room