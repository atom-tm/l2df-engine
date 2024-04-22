local core = assert(l2df, 'L2DF is not available')
local data = assert(data, 'Shared data is not available')

-- UTILS
local log = core.import 'class.logger'
local cfg = core.import 'config'
local Client = core.import 'class.client'

-- COMPONENTS
local States = core.import 'class.component.states'
local Collision = core.import 'class.component.collision'

-- MANAGERS
local SceneManager = core.import 'manager.scene'
local Input = core.import 'manager.input'
local Network = core.import 'manager.network'
local Sync = core.import 'manager.sync'

-- VARIABLES
local unpack = table.unpack or _G.unpack
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

	local checkpoints = { }
	local pendingSyncRequests = { }

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
		data.ready = false
		self.data.hidden = false
		self:setWait(false)
		self.lobby = dummyFunc
		Network:login(('%s#%s'):format(data.players[1], data.usertag))
	end

	function Multiplayer:leave()
		self.inputStream = nil
		self:setWait(false)
		Network:logout()
	end

	function Multiplayer:start()
		Network:logout()
		Sync:mode(Sync.NONE):reset()
		Input:reset(Input.remoteplayers)
		-- Input.delay = cfg.delay or 8
		for _, event in ipairs { 'netupdate' } do
			self:subscribe(event, self[event], nil, self)
		end
		self:resetinput()
		self.R.BACKGROUND().active = false
		self.R.BTN_CANCEL().active = false
		SceneManager:push('game_menu')
	end

	function Multiplayer:resetinput()
		Input:unlock()
		self.inputs = { }
		self.frames = { }
		self.buffer = { }
		checkpoints = { }
		self.inputStream = Input:stream(1)--, Input.localplayers)
		Input:fastforward(self.inputStream)
	end

	function Multiplayer:onresync()
		Sync.desync = false
		self.netresync = nil
		self.netdesync = nil
		log:success('Resync is done')
	end

	function Multiplayer:wait(dt)
		local delay = 0
		for _, c in Network:clients() do
			if not c.ready or c.name < Network.username then return end
			delay = math.max(delay, c:ping())
		end
		delay = math.max(200, math.floor(delay * 2.5))
		data.ready = false
		self.timer = delay * 0.001 + dt
		log:info('[L] Game starts in %fs', self.timer)
		Network:broadcast('netstart', delay)
	end

	local function addNextCheckpoint(snapshot)
		if Sync.desync then return end
		checkpoints[snapshot.frame] = snapshot
	end

	function Multiplayer:netupdate(_, dt)
		local is_alone = true
		for _, c in Network:clients() do
			if c:isConnected() then
				is_alone = false
				break
			end
		end
		if is_alone then return end

		if data.ready then
			self:wait(dt)
		end

		if self.timer then
			self.timer = self.timer - dt
			if self.timer <= 0 then
				data.ontimer(self) -- we're doing smth wrong if there's nil
				self:resetinput()
				self.timer = nil
			end
			return

		elseif Sync.resync == true then
			if not self.netdesync then
				self.netdesync = Sync.frame
				for _, c in Network:clients() do
					c.lastconfirmed = c.lastconfirmed or 0
					c.isresynced = false
					c.ready = false
					c:send('netdesync', self.netdesync, c.lastconfirmed)
				end
				log:debug('SYNC[1] Checkpoint: %05d Sync.frame: %05d', Sync:syncframe(), self.netdesync)
			elseif not self.netresync then
				local max = self.netdesync
				for _, c in Network:clients() do
					if c.lastframe == nil then return end -- waiting for all netdesync
					max = math.max(max, c.lastframe)
				end
				self.netresync = max
				for _, c in Network:clients() do
					local left, input = Input:nearestinput(Input.confirmed[c.player])
					local inputs, frames, hashes, size, chksum = { }, { }, { }, 0, left.hash
					while input do
						size = size + 1
						inputs[size] = input.data
						frames[size] = input.frame
						hashes[size] = input.hash
						chksum = input.hash
						input = input.next
					end
					local s = {
						string.format('[%02d][%05d][%08X] |', left.data, left.frame, left.hash),
					}
					for i = 1, #inputs do
						s[i + 1] = string.format('[%02d][%05d][%08X]', inputs[i], frames[i], hashes[i])
					end
					c:send('netresync', inputs, frames, hashes, chksum)
					log:debug('SENDING[%s] %s', c.name, table.concat(s, ' '))
				end
				log:debug('SYNC[2] Last: %05d From: %05d To: %05d', self.netdesync, Sync.frame, self.netresync)
			else
				for _, c in Network:clients() do
					if not c.isresynced then return end -- waiting for all netresync
					c.lastframe = nil
				end
				Input:reset(Input.remoteplayers, Sync:syncframe(), true)
				Sync.resync = self.netresync
				log:debug('SYNC[3] Checkpoint: %05d Syncpoint: %05d', Sync:syncframe(), self.netresync)
			end
			return

		elseif Sync.desync then
			if self.netresync then
				if Sync.frame < self.netresync then
					log:debug('WAITSYNC Current: %05d Target: %05d', Sync.frame, self.netresync)
					return
				end -- resimulating
				for _, c in Network:clients() do
					if c.isresynced then
						c.isresynced = false
						c:send('netready')
						log:debug('SENTREADY to %s', c.name)
					end
				end
				data.ready = true
				return
			end
			Input:lock()
			data.ontimer = Multiplayer.onresync
			Sync.resync = 1
			self.netdesync = nil
			self.netresync = nil
			self.timer = nil
			return
		end

		-- CHECKPOINTS
		if Sync:is(Sync.ROLLBACK) then
			-- SCHEDULE STATE SYNC
			local syncframe = Sync:syncframe()
			local syncpoint = math.ceil(Sync.frame / data.FPS * 0.5) * 2 * data.FPS
			if checkpoints[syncpoint] == nil then
				checkpoints[syncpoint] = false
				Sync:snapshot(syncpoint, addNextCheckpoint)
			end
			-- PROCESS STATE SYNC
			local invalidated = false
			local i, count = 1, #pendingSyncRequests
			while i <= count do
				local c, f, h = unpack(pendingSyncRequests[i])
				local chkp = checkpoints[f]
				if chkp then
					if chkp.hash == h then
						c.mismatch = 0
						c.frame = math.max(f, c.frame)
						invalidated = true
					elseif c.mismatch < 5 then
						c.mismatch = c.mismatch + 1
						log:warn('MISMATCH %05d: %08X != %08X', f, h, chkp.hash)
					else
						log:error('State mismatch with %s on frame %05d: %08X != %08X', c.name, f, h, chkp.hash)
						Sync.desync = true
					end
					pendingSyncRequests[i] = pendingSyncRequests[count]
					pendingSyncRequests[count] = nil
					count = count - 1
				elseif f < syncframe then
					log:warn('Dropping sync with old frame: %05d [current: %05d]', f, Sync.frame)
					pendingSyncRequests[i] = pendingSyncRequests[count]
					pendingSyncRequests[count] = nil
					count = count - 1
				else
					i = i + 1
				end
			end
			if invalidated then
				local min = Sync.frame
				for _, c in Network:clients() do
					min = math.min(min, c.frame)
				end
				for k, v in pairs(checkpoints) do
					if k < min then
						checkpoints[k] = nil
					end
				end
				if checkpoints[min] then
					Sync:setcheckpoint(checkpoints[min])
				else
					log:warn('Attempt to use checkpoint that doesnt exists! [%05d]', min)
				end
			end
			if Sync.desync then return end
			-- HANDLE STATE SYNC
			local snapshot = nil
			syncpoint = syncframe
			for k, v in pairs(checkpoints) do
				if v and not v.synced and syncframe < k and k < Sync.frame - data.FPS then
					if k > syncpoint then
						syncpoint, snapshot = k, v
					end
					v.synced = true
				end
			end
			if syncpoint ~= syncframe then
				Network:broadcast('netsync', snapshot.frame, snapshot.hash, Sync.time)
			end
		end

		-- INPUT SYNCING
		local size = #self.inputs
		local old = size
		local chksum = 0
		local s = { }
		for _, frame, input, hash, it in self.inputStream do
			size = size + 1
			self.inputs[size] = input
			self.frames[size] = frame
			self.buffer[size] = it
			chksum = hash
		end
		if old ~= size then
			local buffer = { }
			for i = 1, size do
				buffer[i] = string.format('[%02d][%05d][%08X]', self.inputs[i], self.frames[i], self.buffer[i].hash)
			end
			log:debug('SENT %s', table.concat(buffer, ' '))
			if data.isplaying then
				Client.packet_mode = 'unsequenced'
			end
			Network:broadcast('netinput', self.inputs, self.frames, chksum, Sync.time)
			Client.packet_mode = 'reliable'
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
	Network:event('masterconnected', nil, function (c, e)
		if SceneManager:current() == Multiplayer and Multiplayer.lobby == dummyFunc then
			Multiplayer.lobby = Network:list(1, true)
		end
	end)
	Network:event('connected', nil, function (c, e)
		c.player = c.player or Input:newRemotePlayer()
		c.ready = false
		c.frame = 0
		c.mismatch = 0
	end)
	Network:event('verified', nil, function (c, e)
		Multiplayer:start()
	end)
	Network:event('disconnected', nil, function (c, e)
		-- despawn here?
	end)
	Network:event('fps', 'H', function (c, e, fps)
		c.fps = fps
	end)
	Network:event('chat', 's', function (c, e, message)
		log:info('[%s] %s', c.name, message)
	end)
	Network:event('netready', nil, function (c, e)
		c.ready = true
		log:info('%s is READY', c.name)
	end)
	Network:event('netstart', 'H', function (c, e, delay)
		data.ready = false
		Multiplayer.timer = (delay - c:ping() * 0.5) * 0.001
		log:info('[R] Game starts in %fs', Multiplayer.timer)
	end)
	Network:event('netsync', 'IId', function (c, e, frame, hash, time)
		if Sync.desync then return end
		Sync:updateAdvantage(time + c:ping() * 0.0005)
		if c.frame >= frame then return end
		pendingSyncRequests[#pendingSyncRequests + 1] = { c, frame, hash }
		log:info('STATE SYNC [%05d][%08X]', frame, hash)
	end)
	Network:event('netdesync', 'II', function (c, e, frame, cframe)
		Sync.desync = true
		c.lastframe = frame
		Input.confirmed[c.player] = cframe
		log:warn('DESYNC Frame: %s Confirmed: %s', frame, cframe)
	end)
	Network:event('netresync', 'AIAIAII', function (c, e, input, frame, hashes, chksum)
		Input:dropinput(c.lastconfirmed, c.player)
		log:info('NETRESYNC Confirmed: %05d[%d] %08X', c.lastconfirmed, #input, chksum)
		local item = nil
		local s = { }
		for i = 1, #input do
			s[i] = string.format('[%02d][%05d][%08X]', input[i], frame[i], hashes[i])
		end
		log:debug('RECEIVED %s', table.concat(s, ' '))
		for i = 1, #input do
			_, item = Input:addinput(input[i], c.player, frame[i])
		end
		if not item then
			item = Input:lastinput(c.player)
		end
		if item.hash ~= chksum then
			log:crit('CHKSUM mismatch after resync with %s[%d]: L|%08X != R|%08X', c.name, c.player, item.hash, chksum)
			for i = #input + 2, 1, -1 do
				s[i] = string.format('[%02d][%05d][%08X]', item.data, item.frame, item.hash)
				item = item.prev
			end
			log:error('ACTUAL %s', table.concat(s, ' '))
		else
			c.isresynced = true
			c.lastconfirmed = item.frame
			log:info('Resynced input with %s[%d] to %05d', c.name, c.player, c.lastconfirmed)
		end
	end)
	Network:event('netconfirm', 'I', function (c, e, frame)
		if Sync.desync then return end
		Input.confirmed[c.player] = math.max(Input.confirmed[c.player], frame)
		local min = frame
		for i = Input.localplayers + 1, #Input.confirmed do
			local v = Input.confirmed[i]
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
		if Sync.desync then return end
		if c.player then
			Sync:updateAdvantage(time + c:ping() * 0.0005)
			local item = nil
			local s = { }
			for i = 1, #input do
				_, item = Input:addinput(input[i], c.player, frame[i])
				if item.frame ~= frame[i] then
					log:warn('Input frame was changed: %05d -> %05d', frame[i], item.frame)
				end
				s[i] = string.format('[%02d][%05d][%08X]', input[i], frame[i], item.hash)
			end
			log:debug('RECV[%10s] %s', c.name:match('^(.+)#'), table.concat(s, ' '))
			if item.hash == chksum then
				c.lastconfirmed = item.frame
				if data.isplaying then
					Client.packet_mode = 'unsequenced'
				end
				c:send('netconfirm', c.lastconfirmed)
				Client.packet_mode = 'reliable'
			else
				Sync.desync = true
				log:error('Desync InputSize: %d Remote: %08X Local: %08X', #input, chksum, item.hash)
			end
		end
	end)

return Room