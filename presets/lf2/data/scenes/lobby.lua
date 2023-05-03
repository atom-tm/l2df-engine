local core = assert(l2df, 'L2DF is not available')
local data = assert(data, 'Shared data is not available')

-- UTILS
local log = core.import 'class.logger'
local cfg = core.import 'config'

-- COMPONENTS
local Camera = core.import 'class.component.camera'
local Collision = core.import 'class.component.collision'
local Controller = core.import 'class.component.controller'
local SoundSystem = core.import 'class.component.sound'
local CharAttributes = require 'data.scripts.component.attributes'

-- MANAGERS
local Input = core.import 'manager.input'
local Factory = l2df.import 'manager.factory'
local SceneManager = core.import 'manager.scene'
local Network = core.import 'manager.network'

-- VARIABLES
local function dummyFunc() end
local function enableNode(self) self.node.active = true end
local function disableNode(self) self.node.active = false end
local function defaultAction(self, action, ...) (self.node[action] or dummyFunc)(self.node, ...) end

local Room, RoomData = data.layout('layout/lobby.dat')

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

	-- SELECTION CONSTRUCTION
	local AFCOUNT = #RoomData.template.nodes[1].frames
	local SELECTION = Room.R.SELECTION()
	for y = 0, 1 do
		for x = 0, 3 do
			local key = ('T%s_%s'):format(x + 1, y + 1)
			local group = Factory:create('group', RoomData.template, key)
			group.data.x = 153 * x
			group.data.y = 211 * y
			SELECTION:attach(group)
		end
	end

	local TEAMS = { 'Independent', 'Team 1', 'Team 2', 'Team 3', 'Team 4' }

	local function getGroup(player)
		local y = 1
		if player > Input.localplayers then
			y = 2
			player = player - Input.localplayers
		end
		return SELECTION.R[('T%s_%s'):format(player, y)]
	end

	-- BUTTON BINDINGS
	local Menu = Room.R.MENU()
	Menu.R.BTN_FIGHT:onClick(function ()
		local chars = { }
		for i = 1, #Room.data.ready_players do
			local player = Room.data.ready_players[i]
			local chardata = data.chardata:getById(getGroup(player).data.index)
			chardata.playonce = chardata.playonce or cfg.playonce
			chars[i] = Factory:create('object', chardata)
			chars[i]:addComponent(Controller, player)
			chars[i]:addComponent(SoundSystem, chardata)
			chars[i]:addComponent(CharAttributes, chardata)
			chars[i]:addComponent(Camera, { kx = 128, ky = 128 })
		end
		SceneManager:push('battle', chars)
	end)
	Menu.R.BTN_RESET_ALL:onClick(function () Room:enter() end)
	Menu.R.BTN_RESET_RANDOM:onClick(function () Room:randomize() end)
	Menu.R.BTN_EXIT:onClick(function () SceneManager:pop() end)

	for _, btn in Menu.nodes:enum(true) do
		wrapButton(btn)
	end

	function Room:randomize()
		local randoms = self.data.random
		if data.chardata.count == 0 or #randoms == 0 then return end
		for i = 1, #randoms do
			local charid = data.random(1, data.chardata.count)
			randoms[i].data.index = charid
			randoms[i].R.AVATAR.C.frames.set(AFCOUNT + charid)
			randoms[i].R.FIGHTER.data.text = randoms[i].R.AVATAR.data.frame.fighter
		end
	end

	function Room:enable()
		self.active = true
	end

	function Room:disable()
		self.active = false
	end

	function Room:enter()
		log:debug 'Room: LOBBY'
		Menu.active = false
		self.data.counting = false
		self.data.random = { }
		self.data.active_players = 0
		self.data.ready_players = { }
		for _, group in SELECTION.nodes:enum() do
			local avatar = group.R.AVATAR()
			if #avatar.C.frames.data().list - AFCOUNT < data.chardata.count then
				for i, char in data.chardata:enum() do
					avatar.C.frames.add({
						pic = AFCOUNT + i - 1,
						fighter = char.name,
						next = AFCOUNT + i,
						wait = 1000
					}, AFCOUNT + i)
					avatar.C.render.addSprite({ char.head })
				end
			end
			group.R.AVATAR.C.frames.set(1)
			group.R.PLAYER.C.frames.set(1)
			group.R.FIGHTER.C.frames.set(1)
			group.R.TEAM.C.frames.set(1)
			group.R.PLAYER.data.hidden = false
			group.R.PLAYER.data.text = 'Join?'
			group.R.FIGHTER.data.hidden = true
			group.R.FIGHTER.data.text = 'Random'
			group.R.TEAM.data.hidden = true
			group.R.TEAM.data.text = TEAMS[1]
			group.R.TEAM.data.team = 0
			group.data.index = 0
			group.data.ST = 0
		end
	end

	function Room:update()
		if SceneManager:current() ~= self then return end
		if Menu.active then
			if Input:consume('up') then
				Menu:prev()
			end
			if Input:consume('down') then
				Menu:next()
			end
			if Input:consume('attack') then
				Menu:choice()
			end
			return
		end
		local _, left = Input:consume('left')
		local _, right = Input:consume('right')
		local _, atk = Input:consume('attack')
		local _, jmp = Input:consume('jump')
		if atk then
			local group = getGroup(atk)
			if group.data.ST < 3 then
				if group.data.ST == 2 then
					group.TEAM.C.frames.set('idle')
					self.data.ready_players[#self.data.ready_players + 1] = atk
				elseif group.data.ST == 1 then
					group.FIGHTER.C.frames.set('idle')
					group.TEAM.data.hidden = false
				else
					group.AVATAR.C.frames.set(AFCOUNT + group.data.index)
					group.PLAYER.C.frames.set('idle')
					group.PLAYER.data.text = data.players[atk] or tostring(atk)
					group.FIGHTER.data.hidden = false
					self.data.active_players = self.data.active_players + 1
					if self.data.counting then
						self.data.counting = false
						for _, group in SELECTION.nodes:enum() do
							local frameid = group.R.AVATAR.data.frame.id
							if 2 < frameid and frameid < 8 then
								group.R.AVATAR.C.frames.set('join')
							end
						end
					end
				end
				group.data.ST = group.data.ST + 1
			end
		end
		if jmp then
			local group = getGroup(jmp)
			if group.data.ST > 0 and not self.data.counting then
				if group.data.ST == 1 then
					group.AVATAR.C.frames.set('join')
					group.PLAYER.C.frames.set('flicker')
					group.PLAYER.data.text = 'Join?'
					group.FIGHTER.data.hidden = true
					self.data.active_players = self.data.active_players - 1
				elseif group.data.ST == 2 then
					group.FIGHTER.C.frames.set('flicker')
					group.TEAM.data.hidden = true
				else
					group.TEAM.C.frames.set('flicker')
					for i = 1, #self.data.ready_players do
						if self.data.ready_players[i] == jmp then
							table.remove(self.data.ready_players, i)
							break
						end
					end
				end
				group.data.ST = group.data.ST - 1
			elseif self.data.active_players == 0 then
				SceneManager:pop()
			end
		end
		if left or right then
			local sign = right and 1 or -1
			local group = left and getGroup(left) or getGroup(right)
			if group.data.ST == 1 then
				group.data.index = (group.data.index + sign) % (data.chardata.count + 1)
				group.AVATAR.C.frames.set(AFCOUNT + group.data.index)
				group.FIGHTER.data.text = group.AVATAR.data.frame.fighter
			elseif group.data.ST == 2 then
				group.TEAM.data.team = (group.TEAM.data.team + sign) % #TEAMS
				group.TEAM.data.text = TEAMS[group.TEAM.data.team + 1]
			end
		end
		if self.data.active_players > 0 and self.data.active_players == #self.data.ready_players then
			for _, group in SELECTION.nodes:enum() do
				if group.R.AVATAR.data.frame.id < 3 then
					group.R.AVATAR.C.frames.set('count')
					self.data.counting = true
				end
				if group.R.AVATAR.data.frame.id == AFCOUNT - 1 then
					group.R.PLAYER.C.frames.set('idle')
					group.R.PLAYER.data.text = '—'
					Menu.active = true
					self.data.counting = false
				end
			end
		end
		if Menu.active then
			self.data.random = { }
			for _, group in SELECTION.nodes:enum() do
				if group.R.AVATAR().data.frame.keyword == 'random' then
					self.data.random[#self.data.random + 1] = group
				end
			end
			self:randomize()
		end
	end

return Room