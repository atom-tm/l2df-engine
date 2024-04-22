--- Input manager.
-- Controls all available input sources and converts them to internal representation for unified use.
-- @classmod l2df.manager.input
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'InputManager works only with l2df v1.0 and higher')

local log = core.import 'class.logger'
local helper = core.import 'helper'
local packer = core.import 'external.packer'
local Renderer = core.import 'manager.render'
local Resources = core.import 'manager.resource'

local pairs = _G.pairs
local tostring = _G.tostring
local min = math.min
local max = math.max
local ceil = math.ceil
local floor = math.floor
local strlen = string.len
local tremove = table.remove
local ppack = packer.pack
local setKeyRepeat = core.api.io.keyRepeat
local loveGetPosition = core.api.io.mousePosition
local newQuad = core.api.data.quad
local crc32 = helper.crc32
local bitxor = helper.bitxor

local EPS = 1e-10
local MAX_INT = 2 ^ 32

local function bit(p)
	return 2 ^ (p - 1)
end

local function hasbit(x, p)
	return x % (p + p) >= p
end

local function setbit(x, p)
	return hasbit(x, p) and x or x + p
end

local function clearbit(x, p)
	return hasbit(x, p) and x - p or x
end

local function containsPoint(x, y, w, h, px, py, pz)
	return
		px - x > EPS and
		py - y > EPS and
		x + w - px > EPS and
		y + h - py > EPS
end

local function newInput()
	return { data = 0, frame = 0, changes = 0, hash = 0xFFFFFFFF }
end

local function dummy() end

local inputs = { }
local tickrate = core.tickrate or 1
local double_timer = max(3, ceil(0.2 / tickrate))
local islocked = false

local Manager = {
	frame = 0, delay = 0, timer = 0, mousex = 0, mousey = 0, localplayers = 0, remoteplayers = 0,
	buttons = { }, mapping = { }, touches = { }, touchmap = { }, keys = { }, keymap = { },
	ui = { }, consumed = { }, confirmed = { }
}

	--- Internal frame counter. Advances on each @{Manager:advance|InputManager:advance()} call.
	-- @field number Manager.frame

	--- Configure @{l2df.manager.input|InputManager}.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt] table kwargs.keys
	-- @param[opt] number kwargs.uiwidth
	-- @param[opt] number kwargs.uiheight
	-- @param[opt] table kwargs.uilayout
	-- @param[opt] table kwargs.mappings
	-- @param[opt=false] boolean kwargs.key_repeat
	-- @param[opt=false] boolean kwargs.supportui
	-- @return l2df.manager.input
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		if kwargs.key_repeat ~= nil then
			setKeyRepeat(not not kwargs.key_repeat)
		end
		if kwargs.keys then
			self.keys = { }
			self.consumed = { }
			self.keymap = { }
			local keys = kwargs.keys
			for i = 1, #keys do
				self.keys[i] = { keys[i], bit(i) }
				self.consumed[i] = { }
				self.keymap[keys[i]] = i
			end
		end
		if kwargs.uilayout then
			self.ui = { }
			self.touches = { }
			self.touchmap = { }
			local w, h = kwargs.uiwidth or Renderer.width, kwargs.height or Renderer.height
			local ui = kwargs.uilayout
			for i = 1, #ui do
				for key, layout in pairs(ui[i]) do
					if self.keymap[key] then
						self.ui[#self.ui + 1] = layout
						layout.___key = key
						layout.___player = i
						if not layout.x then
							layout.x = layout.right and (w - layout.right) or layout.left or 0
						end
						if not layout.y then
							layout.y = layout.bottom and (h - layout.bottom) or layout.top or 0
						end
						if not layout.w then
							layout.x = layout.left or 0
							layout.w = layout.right and (layout.right - layout.x) or 0
						end
						if not layout.h then
							layout.y = layout.top or 0
							layout.h = layout.bottom and (layout.bottom - layout.y) or 0
						end
						-- layout.renders = layout.renders or { }
						for k = 1, #layout.renders do
							local r = layout.renders[k]
							r.x = (r.x or 0) + (layout.x or 0)
							r.y = (r.y or 0) + (layout.y or 0)
							r.w = r.w or layout.w or 0
							r.h = r.h or layout.h or 0
							r.z = r.z or layout.z or 0
							local obj = r.object
							local quad = r.quad
							if obj then
								if not Resources:loadAsync(obj, not quad and dummy or function (id, img)
									r.quad = newQuad(quad.ox, quad.oy, r.w, r.h, img:getDimensions())
								end) then
									log:error('Data error: %s', obj)
									break
								end
							end
						end
					end
				end
			end
		end
		if kwargs.supportui ~= nil then
			self.supportui = (not not kwargs.supportui) and #self.ui > 0
		end
		if kwargs.mappings then
			self:updateMappings(kwargs.mappings)
		end
		self:reset()
		return self
	end

	--- Reset all inputs and timer of manager.
	-- @param[opt=0] number remote  Remote players count.
	-- @param[opt=0] number zero  Initial @{Manager.frame|InputManager.frame}.
	function Manager:reset(remote, zero, preserve)
		zero = zero or 0
		tickrate = core.tickrate or tickrate
		double_timer = max(3, ceil(0.2 / tickrate))
		self.frame = zero
		self.timer = zero
		self.remoteplayers = remote or 0
		for p = 1, self.localplayers do
			self.buttons[p] = { }
		end
		for i = 1, #self.consumed do
			self.consumed[i] = { }
		end
		self.timers = { }
		self.confirmed = { }
		for p = 1, self.localplayers + self.remoteplayers do
			self.timers[p] = zero
			self.confirmed[p] = zero
		end
		if preserve then
			self:rehash()
			return self:update(0, false)
		end
		if zero > 0 then
			for p = 1, self.localplayers + self.remoteplayers do
				_, inputs[p] = self:dropinput(zero, p)
			end
			return
		end
		inputs = { }
		for p = 1, self.localplayers + self.remoteplayers do
			inputs[p] = newInput()
		end
	end

	---
	function Manager:rehash(player)
		for p = player or 1, player or (self.localplayers + self.remoteplayers) do
			local _, it = self:nearestinput(-1, p)
			it.hash = 0xFFFFFFFF
			while it.next do
				it = it.next
				it.hash = crc32(ppack('III', it.prev.hash, it.data, it.frame))
			end
			log:debug('Rehash for [%s]: [%05d][%08X]', p, it.frame, it.hash)
		end
	end

	--- Advance timer and frame.
	function Manager:advance()
		self.frame = self.frame + 1
		self.timer = max(self.timer, self.frame + self.delay)
	end

	--- Update inputs and render UI for mobile.
	-- @param number dt
	-- @param boolean islast
	function Manager:update(dt, islast)
		for p = 1, self.localplayers + self.remoteplayers do
			local it = inputs[p]
			while it.prev and it.frame >= self.frame do
				it = it.prev
			end
			while it.next and it.next.frame <= self.frame do
				it = it.next
			end
			if it ~= inputs[p] then
				for k = 1, #self.consumed do
					self.consumed[k][p] = nil
				end
			end
			-- log:info('B%02d F%02d [%04x|%05d] -> [%04x|%05d] -> [%04x|%05d]', b, f, it.prev.data, it.prev.frame, it.data, it.frame, it.next.data, it.next.frame)
			inputs[p] = it
		end
		if not islast then return end
		if self.supportui then
			for i = 1, #self.ui do
				local renders = self.ui[i].renders
				for k = 1, #renders do
					Renderer:draw(renders[k])
				end
			end
		else
			self.mousex, self.mousey = loveGetPosition()
		end
	end

	--- Create input source for remote player.
	-- @return number  player's id
	function Manager:newRemotePlayer()
		self.remoteplayers = self.remoteplayers + 1
		local index = self.localplayers + self.remoteplayers
		inputs[index] = newInput()
		self.timers[index] = self.frame
		self.confirmed[index] = self.frame
		return index
	end

	---
	-- @return number  player's id
	function Manager:newBotPlayer()
		self.localplayers = self.localplayers + 1
		local index = self.localplayers + self.remoteplayers
		inputs[index] = newInput()
		self.timers[index] = self.frame
		self.buttons[index] = { }
		return index
	end

	--- Sync mappings with config.
	-- @param table mappings
	function Manager:updateMappings(mappings)
		self.mapping = { }
		self.localplayers = #mappings
		for p = 1, self.localplayers do
			inputs[p] = newInput()
			self.buttons[p] = { }
			for k, v in pairs(mappings[p]) do
				if self.keymap[k] then
					self.mapping[v] = { k, p }
				end
			end
		end
	end

	--- Check if button was pressed at this frame.
	-- @param string button  Hitted button.
	-- @param number player  Player to check or nil to check any local player.
	-- @return boolean
	-- @return number
	function Manager:hitted(button, player, ignore_remotes)
		local keycode = self.keymap[button]
		if keycode then
			keycode = self.keys[keycode][2]
			local input = nil
			for p = player or 1, player or self.localplayers + (ignore_remotes and 0 or self.remoteplayers) do
				input = inputs[p]
				local ishitted = input and input.frame == self.frame and hasbit(input.data, keycode)
				local prev = input and input.prev
				if ishitted and (not prev or prev.frame ~= self.frame and not hasbit(prev.data, keycode)) then
					return true, p
				end
			end
		end
		return false
	end

	--- Check if button was pressed at this frame and consume it for next call.
	-- @param string button  Hitted button.
	-- @param number player  Player to check or nil to check any local player.
	-- @return boolean
	-- @return number
	function Manager:consume(button, player, ignore_remotes)
		local keycode = self.keymap[button]
		if keycode then
			local consumed = self.consumed[keycode]
			local input = nil
			keycode = self.keys[keycode][2]
			for p = player or 1, player or self.localplayers + (ignore_remotes and 0 or self.remoteplayers) do
				if consumed[p] then
					return false
				end
				input = inputs[p]
				local ishitted = input and input.frame == self.frame and hasbit(input.data, keycode)
				local prev = input and input.prev
				if ishitted and (not prev or prev.frame ~= self.frame and not hasbit(prev.data, keycode)) then
					consumed[p] = true
					return true, p
				end
			end
		end
		return false
	end

	--- Check if button was pressed.
	-- @param string button  Pressed button.
	-- @param number player  Player to check or nil to check any local player.
	-- @return boolean
	-- @return number
	function Manager:pressed(button, player, ignore_remotes)
		local index = self.keymap[button]
		if index then
			index = self.keys[index][2]
			local input = nil
			for p = player or 1, player or self.localplayers + (ignore_remotes and 0 or self.remoteplayers) do
				input = inputs[p]
				if input and hasbit(input.data, index) then
					return true, p
				end
			end
		end
		return false
	end

	--- Check if button was double pressed.
	-- @param string button  Doubled button.
	-- @param number player  Player to check or nil to check any local player.
	-- @return boolean
	-- @return number
	function Manager:doubled(button, player, ignore_remotes)
		local index = self.keymap[button]
		if index then
			index = self.keys[index][2]
			local timer, c, a, b, it = self.frame - double_timer
			for p = player or 1, player or self.localplayers + (ignore_remotes and 0 or self.remoteplayers) do
				it, c, a, b = inputs[p], 0, true, false
				while it and it.frame >= timer do
					if hasbit(it.data, index) then
						if not a then break end
						c = c + 1
						a, b = b, a
					elseif b then
						c = c + 1
						a, b = b, a
					end
					it = it.prev
				end
				if c > 2 then
					return true, p
				end
			end
		end
		return false
	end

	--- Check if input data exists.
	-- @param number data
	-- @param number player
	-- @return boolean
	function Manager:check(data, player)
		local input = inputs[player or 1]
		return input and hasbit(input.data, data) or false
	end

	--- Lock
	-- @return l2df.manager.input
	function Manager:lock()
		islocked = true
		return self
	end

	--- Unlock
	-- @return l2df.manager.input
	function Manager:unlock()
		islocked = false
		return self
	end

	--- Get last saved input for specific player.
	-- @param number player
	-- @return number
	function Manager:lastinput(player)
		local input = inputs[player or 1]
		while input.next do
			input = input.next
		end
		return input-- and input.data or 0
	end

	local function debuginput(player, timer)
		local it, data, behind = inputs[player], { }, 0
		while it.next do
			it = it.next
			behind = behind + 1
		end
		for i = 1, 6 do
			data[i] = string.format('[%02d][%05d]', it.data, it.frame)
			if not it.prev then break end
			it = it.prev
		end
		log:info('INPUT[%s] %s | %05d', player, table.concat(data, ' '), timer)
		print(string.rep('_', 7 + 12 * behind) .. '/')
	end

	--- Get nearest to the specified frame input.
	-- @param number frame
	-- @param[opt=1] number player
	-- @return[1] table
	-- @return[2] table
	function Manager:nearestinput(frame, player)
		local left = inputs[player or 1]
		local right = left and left.next
		while left and left.frame > frame do
			right, left = left, left.prev
		end
		while right and right.frame <= frame do
			left, right = right, right.next
		end
		return left, right
	end

	---
	-- @param number frame
	-- @param[opt=1] number player
	-- @return[1] boolean
	-- @return[2] table
	function Manager:dropinput(frame, player)
		local left, right = self:nearestinput(frame, player)
		if left and right then
			left.next = nil
			inputs[player] = left
			-- TODO: mb add here self.frame = frame?
			return true, left
		end
		return false, left
	end

	--- Persist raw input data.
	-- @param number input
	-- @param[opt=1] number player
	-- @param[opt] number timer   Default is current timer.
	-- @return[1] l2df.manager.input
	-- @return[2] l2df.manager.input
	-- @return[2] table
	function Manager:addinput(input, player, timer)
		player = player or 1
		if player > self.localplayers + self.remoteplayers then
			return self
		end
		timer = timer or max(self.timers[player], self.timer)
		local left, right = self:nearestinput(timer, player)
		if left and left.data == input and left.frame == timer then
			return self, left
		elseif left and left.frame == timer then
			-- TODO: fix this input merger
			-- local xor = bitxor(left.data, input)
			-- local changes = bitxor(xor, left.changes)
			-- if bitor(xor, changes) == changes then
			-- 	left.data = input
			-- 	left.changes = changes
			-- 	log:info('INPUT[%05d] for player %s WAS MERGED at %05d!!!', input, player, timer)
			-- 	-- debuginput(player, timer)
			-- 	return self
			-- end
			return self:addinput(input, player, timer + 1)
		end
		local new = {
			prev = left,
			next = right,
			data = input,
			changes = input,
			frame = timer,
			hash = 0xFFFFFFFF,
		}
		if left then
			new.hash = crc32(ppack('III', left.hash, input, timer))
			new.changes = bitxor(left.data, input)
			left.next = new
		end
		if right then
			right.prev = new
			while right do
				right.hash = crc32(ppack('III', right.prev.hash, right.data, right.frame))
				right = right.next
			end
		end
		-- inputs[player] = new
		self.timers[player] = timer
		self.frame = min(timer, self.frame)
		-- debuginput(player, timer)
		return self, new
	end

	--- Save input data for local player.
	-- @param[opt] number player ...
	-- @param[opt] number frame   Default is current timer.
	-- @return l2df.manager.input
	function Manager:saveinput(player, frame)
		for p = player or 1, player or self.localplayers do
			self:addinput(self:rawinput(p), p, frame)
		end
		return self
	end

	--- Stream-function which should be used in `for ... in stream` loops.
	-- @param[opt=1] number player
	-- @param[opt] number last
	-- @return[1] function  Execution data of the returned function is listed below:
	-- @return[2] number  Player ID.
	-- @return[2] number  Frame number.
	-- @return[2] number  Input data.
	-- @return[2] number  CRC32 checksum.
	function Manager:stream(player, last)
		local it = { }
		local from, to = player or 1, last or player or (self.localplayers + self.remoteplayers)
		for p = 1, to do
			it[p] = inputs[p]
		end
		return function ()
			for p = from, to do
				if it[p].next and it[p].next.frame < self.timer then
					it[p] = it[p].next
					return p, it[p].frame, it[p].data, it[p].hash, it[p]
				end
			end
		end
	end

	---
	function Manager:fastforward(stream)
		local t = self.timer
		self.timer = self.frame
		for _ in stream do end
		self.timer = t
	end

	--- Get raw input data for local player.
	-- @param number player
	-- @return number
	function Manager:rawinput(player)
		local buttons = self.buttons[player or 1]
		if not buttons then return 0 end

		local input, kc = 0
		for i = 1, #self.keys do
			kc = self.keys[i]
			if buttons[kc[1]] then
				input = setbit(input, kc[2])
			end
		end
		return input
	end

	--- Button pressed event.
	-- @param string button  Pressed button.
	-- @param number player  Player index.
	-- @return l2df.manager.input
	function Manager:press(button, player)
		if islocked or not button then
			return self
		end
		player = player or 1
		self.buttons[player][button] = true
		self:saveinput(player)
		return self
	end

	--- Button released event.
	-- @param string button  Released button.
	-- @param number player  Player index.
	-- @return l2df.manager.input
	function Manager:release(button, player)
		if islocked or not button then
			return self
		end
		player = player or 1
		self.buttons[player][button] = false
		self:saveinput(player)
		return self
	end

	--- Hook for love.keypressed.
	-- @param string key
	function Manager:keypressed(key)
		local map = self.mapping[key]
		if map then
			self:press(map[1], map[2])
		end
	end

	--- Hook for love.keyreleased.
	-- @param string key
	function Manager:keyreleased(key)
		local map = self.mapping[key]
		if map then
			self:release(map[1], map[2])
		end
	end

	--- Hook for love.mousepressed.
	-- @param number x
	-- @param number y
	-- @param number btn
	-- @param boolean istouch
	function Manager:mousepressed(x, y, btn, istouch)
		if istouch then return end
		btn = btn == 1 and 'lmb' or btn == 2 and 'rmb' or 'mmb'
		self.mousex, self.mousey = x, y
		self:keypressed(btn)
		-- self:touchpressed(1, x, y)
		-- self.lmb = true
	end

	--- Hook for love.mousereleased.
	-- @param number x
	-- @param number y
	-- @param number btn
	-- @param boolean istouch
	function Manager:mousereleased(x, y, btn, istouch)
		if istouch then return end
		btn = btn == 1 and 'lmb' or btn == 2 and 'rmb' or 'mmb'
		self:keyreleased(btn)
		-- self:touchreleased(1, x, y)
		-- self.lmb = false
	end

	--- Hook for love.mousemoved.
	function Manager:mousemoved(x, y, dx, dy, istouch)
		if not self.lmb then return end
		self:touchmoved(1, x, y, dx, dy)
	end

	--- Hook for love.touchpressed.
	function Manager:touchpressed(id, x, y, dx, dy, pressure)
		id = tostring(id)
		local lmb = true
		local sx, sy = Renderer:screenToGame(x, y)
		local touches = self.touches[id] or { }
		self.touches[id] = touches
		for i = 1, #self.ui do
			local btn = self.ui[i]
			if containsPoint(btn.x, btn.y, btn.w, btn.h, sx, sy) then
				lmb = false
				self:press(btn.___key, btn.___player)
				self.touchmap[i] = id
				touches[#touches + 1] = i
			end
		end
		if lmb then
			self.mousex, self.mousey = x, y
			self:keypressed('lmb')
		end
	end

	--- Hook for love.touchreleased.
	function Manager:touchreleased(id, x, y, dx, dy, pressure)
		id = tostring(id)
		local touches = self.touches[id]
		if touches and #touches > 0 then
			for i = #touches, 1, -1 do
				local btn = self.ui[touches[i]]
				if self.touchmap[touches[i]] == id then
					self:release(btn.___key, btn.___player)
					self.touchmap[touches[i]] = nil
				end
				touches[i] = nil
			end
		else
			self:keyreleased('lmb')
		end
	end

	--- Hook for love.touchmoved.
	function Manager:touchmoved(id, x, y, dx, dy, pressure)
		id = tostring(id)
		local sx, sy = Renderer:screenToGame(x, y)
		local pending = { }
		local touches = self.touches[id]
		for i = 1, #self.ui do
			local btn = self.ui[i]
			if containsPoint(btn.x, btn.y, btn.w, btn.h, sx, sy) then
				if not self.touchmap[i] then
					self:press(btn.___key, btn.___player)
					self.touchmap[i] = id
					touches[#touches + 1] = i
				end
			elseif self.touchmap[i] == id then
				pending[#pending + 1] = i
			end
		end
		if #pending > 0 and #touches > 1 then
			for i = #pending, 1, -1 do
				local btn = self.ui[pending[i]]
				for j = #touches, 1, -1 do
					if touches[j] == pending[i] then
						tremove(touches, j)
						self:release(btn.___key, btn.___player)
						self.touchmap[pending[i]] = nil
					end
				end
			end
		end
	end

return setmetatable(Manager, { __call = Manager.init })