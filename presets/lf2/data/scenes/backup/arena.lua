local core = assert(l2df, 'L2DF is not available')
local data = assert(data, 'Shared data is not available')

-- UTILS
local utf8 = require 'utf8'
local helper = core.import 'helper'
local cfg = core.import 'config'
local log = core.import 'class.logger'
local json = core.import 'class.parser.json'

-- COMPONENTS
local Print = core.import 'class.component.print'
local World = core.import 'class.component.physix.world'
local Camera = core.import 'class.component.camera'
local Frames = core.import 'class.component.frames'
local Behaviour = core.import 'class.component.behaviour'
local Controller = core.import 'class.component.controller'
local PlayerState = require 'data.scripts.components.PlayerState'

-- MANAGERS
local Factory = core.import 'manager.factory'
local SceneManager = core.import 'manager.scene'
local RenderManager = core.import 'manager.render'
local Recorder = core.import 'manager.recorder'
local Network = core.import 'manager.network'
local Input = core.import 'manager.input'
local Sync = core.import 'manager.sync'

-- VARIABLES
local playerOnline = nil
local players = { }
local selectors = { }

local function dummyFunc() end

local Room, RoomData = data.layout('layout/arena.dat')

	_, Room.map = Room:attach(data.map(RoomData.maps[1]))
	Room.timer = Room.R.TIMER:getComponent(Print)
	Room.debug = Room.R.DEBUG()
	Room.input = Room.R.INPUT()
	Room.chat = Room.R.CHAT()
	Room.sync = Room.R.SYNC()
	Room.prompt = Room.R.SELECTION_PROMPT()
	Room.ATK = Room.R.CONTROL.ATK.LABEL:getComponent(Print)
	Room.JMP = Room.R.CONTROL.JMP.LABEL:getComponent(Print)
	Room.DEF = Room.R.CONTROL.DEF.LABEL:getComponent(Print)
	Room.CONTROL = Room.R.CONTROL()
	Room.SM = Behaviour:wrap(Room)
	Room:addComponent(Room.SM())

	--- STATES
	local SDefault = { }
	local SChat = { }
	local SLobby = { delay = 0 }
	local SLobbyList = { join = '' }
	local SLobbyJoin = { }
	local SLobbyOnline = { }
	local SDebug = { window = 1, lag = 0, rollback = -1, frame = -1, before = nil, after = nil, waiting = false }
	local SMultiplayer = { inputs = nil, frames = nil, inputStream = nil, timer = 0 }

	---
	local function spawnChar(charid, spawnx, spawny)
		local chardata = data.chardata:getById(charid)
		local char = Factory:create('object', chardata)
		char.charid = charid
		char.spawnx = spawnx
		char.spawny = spawny

		if chardata.stand then
			local stand = Factory:create(chardata.stand)
			stand.data.x = spawnx + 32
			stand.data.z = spawny
			stand.char = char
			char.stand = stand
		end

		char.data.x = spawnx
		char.data.z = spawny
		char.data.y = cfg.height
		char.data.vy = -3210
		char.data.globalX, char.data.globalY = -1000, -1000
		_, players[#players + 1] = Room.map:attach(char)
		return char
	end

	---
	local function despawnChar(char)
		local len = #players
		for i = len, 1, -1 do
			if players[i] == char then
				players[i] = players[len]
				players[len] = nil
				char:destroy()
				break
			end
		end
	end

	---
	local function wrapChar(char, client)
		char.cc = client
		char.cc.obj = char
		char.cc.player = char.data.player
		char.cc.charid = char.charid
		char.cc.spawnx = char.spawnx
		char.cc.spawny = char.spawny
	end

	--- Replay loader callback
	local function loadReplay(metadata)
		local meta = json:parse(metadata)
		Room:clear()
		SDefault:start()
		for i = 1, #meta do
			while meta[i].player > Input.remoteplayers do
				Input:newRemotePlayer()
			end
			local obj = spawnChar(meta[i].char, meta[i].x, meta[i].y)
			obj:addComponent(Controller, Input.localplayers + meta[i].player)
			obj:addComponent(PlayerState)
			players[i] = obj
		end
		return Input.localplayers
	end

	---
	local function previewWatcher(self)
		for char in self:enum(false, true) do
			char.data.hidden = self.data.state <= 1
		end
	end

	---
	local function previewUpdate(self)
		if not Room.SM.has(SLobby) then
			return
		end
		local _, playerATK = Input:consume('attack')
		local _, playerLeft = Input:consume('left')
		local _, playerRight = Input:consume('right')
		if self.data.player == playerLeft then
			self:prev()
		end
		if self.data.player == playerRight then
			self:next()
		end
		if self.data.player == playerATK then
			self:choice()
		end
	end

	---
	local function previewSelector(self)
		self.parent:detachParent()
		self.parent.spawned = spawnChar(self.data.charid, self.parent.data.x, self.parent.data.z)
		Room.SM.invoke('spawn', self.parent.spawned, self.data.player)
	end

	---
	local function previewGenerate(player, x, y)
		local preview = Factory:create('menu')
		for id, char in data.chardata:enum() do
			if char.preview then
				local _, button = preview:attach(Factory:create('button', char.preview))
				button.data.charid = id
				button.data.player = player
				button:onClick(previewSelector)
				button:onChange(previewWatcher)
				button.R.GROUP.LABEL.data.y = y
			end
		end
		preview.data.x, preview.data.z = x, y
		preview.data.player = player
		preview.update = previewUpdate
		return preview
	end

	--- Rollback network
	local function makeSnapshot()
		for obj in Room.map:enum() do
			Sync:stage(obj.sync, obj, obj:sync())
			if obj.stand then
				Sync:stage(obj.stand.sync, obj.stand, obj.stand:sync())
			end
		end
	end

	--- CALLBACKS
	function Room:enter()
		playerOnline = nil
		self.sync.active = false
		self.prompt.active = true
		self.chat:clear()
		self.input:clear()
		self.timer.data().text = ''
		Print:data(self.debug).text = ''
		self.SM.switch(SDefault)
		self.SM.append(SLobby)
		for _, event in ipairs { 'keypressed', 'textinput', 'netupdate', 'filedropped' } do
			self:subscribe(event, self.SM().invoke, nil, self.SM(), Room, event)
		end
		if data.replay then
			SDefault:replay(data.replay)
			data.replay = nil
		end
	end

	function Room:leave()
		self:clear()
		self.SM.clear()
		for _, event in ipairs { 'keypressed', 'textinput', 'netupdate', 'filedropped' } do
			self:unsubscribe(event, self.SM().invoke)
		end
		SLobbyOnline.delay = 0
		Recorder:close()
		Recorder:stop()
		Network:destroy()
		Sync:reset()
	end

	function Room:preupdate()
		love.window.setTitle('Bizarre Slaughter | FPS: ' .. tostring(love.timer.getFPS()))
	end

	function Room:clear()
		for k, s in pairs(selectors) do
			s:destroy()
			selectors[k] = nil
		end
		for i = 1, #players do
			if players[i].cc then
				players[i].cc.obj = nil
				players[i].cc:disconnect()
			end
			players[i] = players[i]:destroy()
		end
		self.map:detachAll()
	end

	function Room:tooltip(atk, jmp, def)
		local a, j, d = self.ATK.data(), self.JMP.data(), self.DEF.data()
		local at, jt, dt = a.text or '', j.text or '', d.text or ''
		a.text = atk or at
		j.text = jmp or jt
		d.text = def or dt
		self.ATK.object.parent.active = a.text ~= ''
		self.JMP.object.parent.active = j.text ~= ''
		self.DEF.object.parent.active = d.text ~= ''
		self.CONTROL.active = a.text ~= '' or j.text ~= '' or d.text ~= ''
		return at, jt, dt
	end

	function SDefault:start()
		Input:reset(Input.remoteplayers)
		Sync:reset()
		Sync.persist(makeSnapshot)
		while Room.SM.data().size > 1 do
			Room.SM.pop()
		end
		Room.SM.push(self)
		if cfg.debug then
			Room.SM.append(SDebug)
		end
	end

	function SDefault:replay(path)
		SChat:print('System', 'Opening %s...', path)
		if Recorder:open(path, loadReplay) then
			Room:tooltip('', '', '')
			Room.prompt.active = false
		else
			SChat:print('System', 'Can\'t open replay')
		end
	end

	function SDefault:filedropped(file)
		local path = file:getFilename()
		if not path:match('%.replay') then return end
		self:replay(path)
	end

	function SDefault:keypressed(key)
		if key == 'tab' then
			Room.chat.data.hidden = not Room.chat.data.hidden
		elseif key == 'escape' then
			SceneManager:set('menu')
		elseif key == 'f10' then
			RenderManager.DEBUG = not RenderManager.DEBUG
		end
	end

	function SLobby:enable()
		Room:tooltip('Select character', 'Back', 'Online mode')
	end

	function SLobby:ready(char, isready)
		char.ready = isready or nil
		local count = #players
		if count < 2 then return end
		for i = 1, count do
			if players[i].ready then
				count = count - 1
			end
		end
		if count == 0 then
			Room.SM.invoke('gameready', 0, true)
		end
	end

	local GAMESTART_DELAY = 3
	function SLobby:gameready(delay)
		Room:tooltip('', '', '')
		Room.prompt.active = false
		self.delay = self.delay + GAMESTART_DELAY - delay
	end

	function SLobby:gamestart()
		Room.timer.data().text = ''
		SDefault:start()
		for i = 1, #players do
			players[i].C.frames.set(1)
			players[i]:addComponent(Controller)
			players[i]:addComponent(PlayerState)
			if players[i].data.player <= Input.localplayers then
				players[i]:addComponent(Camera, { kx = 128, ky = 128 })
			end
		end
	end

	function SLobby:postupdate(dt)
		for i = 1, #players do
			if players[i].ready and not players[i].data.isready then
				players[i].C.frames.set('intro')
				players[i].data.isready = true
			end
		end
		if self.delay <= 0 then return end
		self.delay = self.delay - dt
		if self.delay > 0 then
			Room.timer.data().text = string.format('%.1f', self.delay)
			return
		end
		Room.SM.invoke('gamestart')
		self.delay = 0
	end

	function SLobby:preupdate()
		if self.delay > 0 then return end
		local isATK, playerATK = Input:hitted('attack')
		local isJMP, playerJMP = Input:hitted('jump')
		local isDEF, playerDEF = Input:hitted('defend')
		-- Special online checks
		if isATK and playerOnline and playerATK ~= playerOnline then
			return
		end
		-- Spawn character selector
		if isATK and not selectors[playerATK] then
			Input:consume('attack', playerATK)
			local spawnx = math.random(cfg.width  * 0.05, cfg.width  * 0.95)
			local spawny = math.random(cfg.height * 0.60, cfg.height * 0.80)
			selectors[playerATK] = previewGenerate(playerATK, spawnx, spawny)
			Room.map:attach(selectors[playerATK])
		-- Mark as ready to play
		elseif isATK and selectors[playerATK].spawned and not selectors[playerATK].spawned.ready then
			Room.SM.invoke('ready', selectors[playerATK].spawned, true)
		-- Remove selected player
		elseif isJMP and selectors[playerJMP] and selectors[playerJMP].spawned then
			Room.SM.invoke('despawn', selectors[playerJMP].spawned, playerJMP)
			selectors[playerJMP].spawned = nil
		-- Remove player selector
		elseif isJMP and selectors[playerJMP] then
			selectors[playerJMP] = selectors[playerJMP]:destroy()
		-- Go back to menu
		elseif isJMP and not next(selectors) then
			SceneManager:set('menu')
		-- Enable online
		elseif isDEF and (not playerOnline or playerDEF == playerOnline) then
			playerOnline = playerDEF
			for player, selector in pairs(selectors) do
				if player ~= playerOnline then
					selector.spawned = selector.spawned and despawnChar(selector.spawned)
					selectors[player] = selector:destroy()
				end
			end
			Room.SM.push(SLobbyList)
		end
	end

	function SLobby:spawn(char, player)
		char.data.player = player
	end

	function SLobby:despawn(char, player)
		if player <= Input.localplayers then
			Room.map:attach(selectors[player])
		end
		despawnChar(char)
	end

	function SLobbyOnline:ready()
		Network:broadcast('ready')
	end

	function SLobbyOnline:gameready(delay, islocal)
		Room.chat:clear()
		Network:logout()
		if not islocal then return end
		local ping = 0
		for _, c in Network:clients() do
			ping = math.max(ping, c:ping())
		end
		if Network:broadcast('gameready') then
			SLobby.delay = SLobby.delay - ping * 0.0005
		end
	end

	function SLobbyOnline:gamestart()
		SMultiplayer:start()
	end

	function SLobbyOnline:spawn(char, player)
		if player <= Input.localplayers then
			local client = Network:clients('local')
			if client then
				wrapChar(char, client)
			end
			Network:broadcast('spawn', char.charid, char.spawnx, char.spawny)
		end
	end

	function SLobbyOnline:despawn(char, player)
		if player <= Input.localplayers then
			Network:broadcast('despawn')
		end
	end

	function SLobbyOnline:localchat(msg)
		if Network:isConnected() then
			Network:broadcast('chat', msg)
		end
	end

	function SLobbyList:enable()
		Room:tooltip('Select', '', 'Close window')
		self.lobbies = dummyFunc
		self.menu = Room.R.LOBBIES()
		self.host = self.menu.R.HOST()
		self.join = self.menu.R.JOIN()
		self.input = self.join.data.states[2]
		self.menu.active = true
		self.host:onClick(function ()
			Network:host()
			self.menu:disable()
		end)
		self.join:onClick(function ()
			if not Room.SM.has(SLobbyJoin) then
				Room.SM.append(SLobbyJoin)
			end
		end)
		self.loader = self.menu.R.LOADER()
		self.list = self.menu.R.LIST()
		if Network:isReady() then
			self:refresh()
		else
			self.loader.active = true
			self.menu:disable()
			Network:login(string.format('%s#%s', cfg.general.name, cfg.general.tag))
		end
	end

	function SLobbyList:disable()
		self.menu.active = false
	end

	function SLobbyList:refresh()
		self.refreshing = true
		self.loader.active = true
		self.menu:disable()
		self.list:detachAll()
		self.lobbies = Network:list(10, true)
	end

	function SLobbyList:lobby(id)
		Room.timer.data().text = id
		Room.SM.pop()
		if not Room.SM.has(SLobbyOnline) and not Room.SM.has(SMultiplayer) then
			Room.SM.append(SLobbyOnline)
		end
		local client = Network:clients('local') or Network:addClient('local', Network.username)
		for i = 1, #players do
			if players[i].data.player == playerOnline then
				wrapChar(players[i], client)
				break
			end
		end
	end

	function SLobbyList:preupdate()
		-- Refreshing lobbies list
		local lobbies = self.lobbies()
		if self.refreshing and lobbies ~= nil then
			self.menu:enable()
			self.refreshing = false
			self.loader.active = false
			for i = 1, #lobbies do
				local text = string.format('%.10s | %s', lobbies[i].id, table.concat(lobbies[i].players, ', '))
				self.list:attach(Factory:create('button', {
					x = 0, y = 8 + 32 * (i - 1),
					states = {
						normal   = { _type = 'text', text = text, font = 16, centerx = -8, w = 768, h = 24, bgcolor = { 0, 0, 0, 64 } },
						focus    = { _type = 'text', text = text, font = 16, centerx = -8, w = 768, h = 24, bgcolor = { 0, 0, 0, 128 } },
						disabled = { _type = 'text', text = text, font = 16, centerx = -8, w = 768, h = 24, bgcolor = { 0, 0, 0, 32 } },
					}
				}):onClick(function ()
					Network:join(lobbies[i].id)
				end))
			end
			self.list:select(1)
			if self.menu:current() ~= self.list then
				self.list:disable()
			end
		end
		-- Entering lobby id to join
		if Room.SM.has(SLobbyJoin) then
			return
		end
		Print:data(self.join.nodes:first()).text = self.input:getText()
		-- Menu controls
		local hmove = Input:hitted('left') and 'prev' or Input:hitted('right') and 'next' or nil
		local vmove = Input:hitted('up') and 'prev' or Input:hitted('down') and 'next' or nil
		if Input:consume('select') or Input:consume('attack') then
			self.menu:choice()
		elseif Input:consume('defend') then
			Room.SM.pop()
		elseif self.menu:current() ~= self.list then
			if vmove and self.list.nodes.count > 0 then
				while self.menu:current() ~= self.list do 
					self.menu[vmove](self.menu)
				end
				self.list:enable()
			elseif hmove then
				self.menu[hmove](self.menu)
				if self.menu:current() == self.list then
					self.menu[hmove](self.menu)
				end
			end
			return
		elseif vmove == 'prev' then
			if self.list:current() == self.list:first() then
				self.list:disable()
				self.menu:prev()
			else
				self.list:prev()
			end
		elseif vmove == 'next' then
			if self.list:current() == self.list:last() then
				self.list:disable()
				self.menu:next()
			else
				self.list:next()
			end
		end
	end

	function SLobbyJoin:enable()
		self.at, self.jt, self.dt = Room:tooltip('', '', '')
		love.keyboard.setKeyRepeat(true)
	end

	function SLobbyJoin:disable()
		Room:tooltip(self.at, self.jt, self.dt)
		love.keyboard.setKeyRepeat(false)
	end

	function SLobbyJoin:preupdate()
		if Input:consume('select') then
			local text = helper.trim(SLobbyList.input:getText())
			if text ~= '' then
				Network:join(text)
			end
			Room.SM.remove(self)
		end
	end

	function SLobbyJoin:keypressed(key)
		if key == 'backspace' then
			SLobbyList.input:erase()
		end
	end

	function SLobbyJoin:textinput(char)
		SLobbyList.input:append(char)
	end

	function SMultiplayer:start()
		local metadata = { }
		self.confirmed = { }
		for _, c in Network:clients() do
			if c.obj then
				metadata[#metadata + 1] = {
					user = c.name,
					x = c.spawnx,
					y = c.spawny,
					player = c.player,
					char = c.charid,
				}
			else
				c:disconnect()
			end
		end
		love.filesystem.createDirectory('replays')
		local replay = string.format('%s/%s-%s.replay', core.savepath('replays'), Network.username, os.date('%Y%m%d-%H%M%S'))
		Recorder:start(replay, json:dump(metadata, true), Input:stream(), 2)
		Input.delay = cfg.general.delay or Input.delay
		self.inputStream = Input:stream(1)
		self.inputs = { }
		self.frames = { }
		self.buffer = { }
		Room.SM.append(self)
	end

	function SMultiplayer:netupdate()
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
			log:info('SENT[%10s] %s', Network:clients('local').name:match('^(%w+)#'), table.concat(self.buffer, ' '))
			Network:broadcast('netinput', self.inputs, self.frames, chksum, Sync.time)
		end
	end

	function SMultiplayer:despawn(char, player)
		-- if player <= Input.localplayers then end
		despawnChar(char)
	end

	local FPS_REFRESH_RATE = 2
	function SMultiplayer:preupdate(dt)
		Room.sync.active = Sync.desync
		self.timer = self.timer + dt
		if self.timer > FPS_REFRESH_RATE then
			local fps = love.timer.getFPS()
			self.timer = self.timer - FPS_REFRESH_RATE
			Network:clients('local').fps = fps
			Network:broadcast('fps', fps)
		end
	end

	function SMultiplayer:postupdate()
		if Sync.desync then
			-- TODO: SYNC game states
		end
	end

	function SChat:print(name, message, ...)
		if name and name:lower() == 'system' then
			log:info(message, ...)
		end
		Room.chat:prepend(string.format('[%s]: %s\n', name, message:format(...)))
	end

	function SChat:keypressed(key)
		if key == 'backspace' then
			Room.input:erase()
		elseif key == 'return' then
			local msg = helper.trim(Room.input:getText())
			if msg == '' then return end
			Room.input:clear()
			SChat:print(Network.username, msg)
			Room.SM.invoke('localchat', msg)
		end
	end

	function SChat:textinput(char)
		Room.input:append(char)
	end

	function SDebug:enable()
		Room.chat.data.hidden = true
		self:test(-1, 0, 0)
		-- self:test(696, 0, 696 - 695) -- b#8237-20210207-155154.replay
		-- self:test(2381, 0, 2381 - 2327) -- Plavil7721.replay
		-- self:test(167, 0, 167 - 109) -- Kasai3163.replay
	end

	function SDebug:test(frame, delay, window)
		self.waiting = true
		self.before = nil
		self.after = nil
		self.speed = 1
		self.frame = frame + delay
		self.rollback = frame + delay - window
	end

	function SDebug:collectInfo()
		local info = { }
		for obj in Room.map:enum(true, true) do
			local size, wait, current, next, counter = obj.C.frames.stats()
			info[#info + 1] = string.format('%s[%s] - input[%04x|%05d] hp[%04d] x[%.2f] y[%.2f] z[%.2f] vx[%.2f|%.2f] vz[%.2f|%.2f] fps[%s] ping[%.0fms] frame[%s/%s] next[%s] counter[%.2f]\n',
				obj.cc and obj.cc.name or obj.char and 'stand' or 'player',
				obj.cc and obj.cc:state() or obj.data.player or 0,
				Input:lastinput(obj.data.player).data, Input:lastinput(obj.data.player).frame,
				PlayerState:data(obj).hp or 0,
				obj.data.x, obj.data.y, obj.data.z, obj.data.vx, obj.data.dvx, obj.data.vz, obj.data.dvz,
				obj.cc and obj.cc.fps or '?',
				obj.cc and obj.cc:ping() or 0,
				current, size, next, counter
			)
		end
		table.sort(info)
		return table.concat(info, '')
	end

	function SDebug:debuginput(player)
		local it, data, behind = Input:lastinput(player), { }, 0
		while it.next do
			it = it.next
			behind = behind + 1
		end
		while it ~= nil do
			data[#data + 1] = string.format('[%02d][%05d][%08X]', it.data, it.frame, it.hash)
			it = it.prev
		end
		log:info(string.format('INPUT[%s] %s', player, table.concat(data, ' ')))
		-- print(string.rep('_', 7 + 12 * behind) .. '/')
	end

	function SDebug:preupdate()
		local debug = self:collectInfo()
		if self.rollback <= Sync.frame and Sync.frame <= self.frame then
			log:info('Time: %.2fs Frame: [S%05d|I%05d]\n%s', Sync.time, Sync.frame, Input.frame, debug)
		end
		if Sync.frame == self.rollback then
			if self.before then
				assert(self.before == debug, 'COMPARE BEFORE FAILED')
			else
				self.before = debug
			end
		end
		if Sync.frame == self.frame then
			if self.after then
				assert(self.after == debug, 'COMPARE AFTER FAILED')
				self:test(Sync.frame, 1 + math.random(0, 4) * 60, math.random(self.window))
			else
				self.after = debug
			end
		end
		Print:data(Room.debug).text = debug
		Print:data(Room.input).text = string.format('Time: %.2fs Frame: [%05d/%05d] Lag: %.3f Speed: %2d Rollback: [%05d -> %05d | %02d]',
			Sync.time, Sync.frame, Input.timer, self.lag, self.speed, self.frame, self.rollback, self.window
		)
	end

	function SDebug:postupdate()
		if Sync.frame == self.frame and self.waiting then
			Input.frame = self.rollback - 1
			self.waiting = false
		end
		if self.lag > 0 then
			love.timer.sleep(self.lag)
		end
	end

	function SDebug:keypressed(key)
		if key == 'f1' then
			self.lag = self.lag + 0.001
		elseif key == 'f2' and self.lag > 0 then
			self.lag = self.lag - 0.001
		elseif key == 'f3' then
			self:debuginput(5)
			self:debuginput(3)
		elseif key == 'f4' then
			self.speed = self.speed - 1
			if self.speed == 0 then self.speed = -1 end
			l2df:speedup(self.speed)
		elseif key == 'f5' then
			if l2df.speed == 0 then
				l2df:speedup(self.speed)
			else
				l2df:speedup(0)
			end
		elseif key == 'f6' then
			self.speed = self.speed + 1
			if self.speed == 0 then self.speed = 1 end
			l2df:speedup(self.speed)
		elseif key == 'f8' then
			self:test(Sync.frame, self.window - 1, self.window - 1)
			log:info('Manual rollback test\nTime: %.2fs Frame: [S%05d|I%05d]\n%s', Sync.time, Sync.frame, Input.frame, self:collectInfo())
		elseif key == 'f9' then
			self:test(-1, 0, 0)
		elseif key == 'f10' then
			Room.debug.data.hidden = not Room.debug.data.hidden
		elseif key == 'f11' then
			self.window = self.window + 1
		elseif key == 'f12' and self.window > 0 then
			self.window = self.window - 1
		end
	end

	--- NETWORKING
	Network:register(cfg.general.master or '127.0.0.1:12565')
	Network:event('masterconnected', nil, function (c, e)
		SLobbyList:refresh()
	end)
	Network:event('masterlobby', nil, function (c, e, id)
		Room.SM.invoke('lobby', id)
	end)
	Network:event('connected', nil, function (c, e)
		c.player = c.player or Input:newRemotePlayer()
	end)
	Network:event('verified', nil, function (c, e)
		local client = Network:clients('local')
		if client and client.charid then
			c:send('spawn', client.charid, client.spawnx, client.spawny)
		end
		SChat:print('System', '%s connected', c.name)
	end)
	Network:event('spawn', 'bHH', function (c, e, id, x, y)
		local char = spawnChar(id, x, y)
		Room.SM.invoke('spawn', char, c.player)
		wrapChar(char, c)
	end)
	Network:event('despawn', nil, function (c, e)
		if c.obj then
			Room.SM.invoke('despawn', c.obj, c.player)
			c.obj = nil
		end
	end)
	Network:event('disconnected', nil, function (c, e)
		if c.obj then
			Room.SM.invoke('despawn', c.obj, c.player or 10000)
			c.obj = nil
		end
		SChat:print('System', '%s disconnected', c.name or tostring(c.peer))
	end)
	Network:event('fps', 'H', function (c, e, fps)
		c.fps = fps
	end)
	Network:event('chat', 's', function (c, e, message)
		SChat:print(c.name, message)
	end)
	Network:event('ready', nil, function (c, e)
		if c.obj then
			c.obj.ready = true
			log:info('Player %s[%s] is READY', c.name, c.player)
		end
	end)
	Network:event('gameready', nil, function (c, e)
		Room.SM.invoke('gameready', c:ping() * 0.0005)
	end)
	Network:event('netconfirm', 'I', function (c, e, frame)
		SMultiplayer.confirmed[c.player] = math.max(SMultiplayer.confirmed[c.player] or 0, frame)
		local min = frame
		for _, v in pairs(SMultiplayer.confirmed) do
			if v < min then
				min = v
			end
		end
		local start = #SMultiplayer.frames
		for i = 1, start do
			if SMultiplayer.frames[i] > min then
				start = i - 1
				break
			end
		end
		if start == 0 then return end
		for i = 1, #SMultiplayer.inputs do
			SMultiplayer.inputs[i] = SMultiplayer.inputs[start + i]
			SMultiplayer.frames[i] = SMultiplayer.frames[start + i]
			SMultiplayer.buffer[i] = SMultiplayer.buffer[start + i]
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