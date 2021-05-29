--- Input manager.
-- Controls all available input sources and converts them to internal representation for unified use.
-- @classmod l2df.manager.input
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'InputManager works only with l2df v1.0 and higher')

local log = core.import 'class.logger'
local helper = core.import 'helper'

local pairs = _G.pairs
local min = math.min
local max = math.max
local ceil = math.ceil
local setKeyRepeat = love.keyboard.setKeyRepeat

local inputs = { }

local function bit(p)
	return 2 ^ (p - 1)
end

local function bitor(x, y)
    local k, c = 1, 0
    while x + y > 0 do
        local rx, ry = x % 2, y % 2
        if rx + ry > 0 then c = c + k end
        x, y, k = (x - rx) / 2, (y - ry) / 2, k * 2
    end
    return c
end

local function bitxor(x, y)
    local k, c = 1, 0
    while x > 0 and y > 0 do
        local rx, ry = x % 2, y % 2
        if rx ~= ry then c = c + k end
        x, y, k = (x - rx) / 2, (y - ry) / 2, k * 2
    end
    x = x < y and y or x
    while x > 0 do
        local rx = x % 2
        if rx > 0 then c = c + k end
        x, k = (x - rx) / 2, k * 2
    end
    return c
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

local function newInput()
	return { data = 0, frame = 0, changes = 0 }
end

local tickrate = core.tickrate or 1
local double_timer = max(3, ceil(0.2 / tickrate))

local Manager = { frame = 0, delay = 0, timer = 0, buttons = { }, mapping = { }, keys = { }, keymap = { } }

	--- Configure @{l2df.manager.input|InputManager}.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt] table kwargs.keys
	-- @param[opt] table kwargs.mappings
	-- @param[opt=false] boolean kwargs.key_repeat
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		setKeyRepeat(kwargs.key_repeat or false)
		self.localplayers = 0
		self.remoteplayers = 0
		self.keys = { }
		self.keymap = { }
		self.consumed = { }
		self:reset()
		local keys = kwargs.keys or { }
		for i = 1, #keys do
			self.keys[i] = { keys[i], bit(i) }
			self.consumed[i] = { }
			self.keymap[keys[i]] = i
		end
		if kwargs.mappings then
			self:updateMappings(kwargs.mappings)
		end
		return self
	end

	--- Reset all inputs and timer of manager.
	-- @param[opt=0] number remote
	function Manager:reset(remote)
		self.timer = 0
		self.frame = 0
		self.delay = 0
		self.remoteplayers = remote or 0
		tickrate = core.tickrate or tickrate
		double_timer = max(3, ceil(0.2 / tickrate))
		inputs = { }
		for p = 1, self.localplayers do
			self.buttons[p] = { }
			inputs[p] = newInput()
		end
		for p = self.localplayers + 1, self.localplayers + self.remoteplayers do
			inputs[p] = newInput()
		end
	end

	--- Advance timer and frame.
	function Manager:advance()
		self.frame = self.frame + 1
		self.timer = max(self.timer, self.frame + self.delay)
	end

	--- Update inputs.
	function Manager:update()
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
	end

	--- Create input source for remote player.
	-- @return number  player's id
	function Manager:newRemotePlayer()
		self.remoteplayers = self.remoteplayers + 1
		inputs[self.localplayers + self.remoteplayers] = newInput()
		return self.localplayers + self.remoteplayers
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
	function Manager:hitted(button, player)
		local keycode = self.keymap[button]
		if keycode then
			keycode = self.keys[keycode][2]
			local input = nil
			for p = player or 1, player or self.localplayers do
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
	function Manager:consume(button, player)
		local keycode = self.keymap[button]
		if keycode then
			local consumed = self.consumed[keycode]
			local input = nil
			keycode = self.keys[keycode][2]
			for p = player or 1, player or self.localplayers do
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
	function Manager:pressed(button, player)
		local index = self.keymap[button]
		if index then
			index = self.keys[index][2]
			local input = nil
			for p = player or 1, player or self.localplayers do
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
	function Manager:doubled(button, player)
		local index = self.keymap[button]
		if index then
			index = self.keys[index][2]
			local timer, c, a, b, it = self.frame - double_timer
			for p = player or 1, player or self.localplayers do
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

	--- Get last saved input for specific player.
	-- @param number player
	-- @return number
	function Manager:lastinput(player)
		local input = inputs[player or 1]
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
		log:info(string.format('INPUT[%s] %s | %05d', player, table.concat(data, ' '), timer))
		print(string.rep('_', 7 + 12 * behind) .. '/')
	end

	--- Persist raw input data.
	-- @param number input
	-- @param[opt=1] number player
	-- @param[opt] number timer   Default is current timer.
	-- @return l2df.manager.input
	function Manager:addinput(input, player, timer)
		player = player or 1
		if player > self.localplayers + self.remoteplayers then
			return self
		end
		timer = timer or self.timer
		local left = inputs[player]
		local right = left and left.next
		while left and left.frame > timer do
			right, left = left, left.prev
		end
		while right and right.frame <= timer do
			left, right = right, right.next
		end
		if left and left.frame == timer then
			-- TODO: fix this input merger
			local changes = bitxor(xor, left.changes)
			if bitor(xor, changes) == changes then
				left.data = input
				left.changes = changes
				log:info('INPUT[%05d] for player %s WAS MERGED at %05d!!!', input, player, timer)
				-- debuginput(player, timer)
				return self
			end
			return self:addinput(input, player, timer + 1)
		elseif left and left.data == input then
			return self
		end
		local new = {
			prev = left,
			next = right,
			data = input,
			changes = input,
			frame = timer,
		}
		if left then
			new.changes = bitxor(left.data, input)
			left.next = new
		end
		if right then
			right.prev = new
		end
		-- inputs[player] = new
		self.timer = timer
		self.frame = min(timer, self.frame)
		-- debuginput(player, timer)
		return self
	end

	--- Save input data for local player.
	-- @param[opt] number player ...
	-- @param[opt] number frame   Default is current timer.
	-- @return number
	function Manager:saveinput(player, frame)
		for p = player or 1, player or self.localplayers do
			self:addinput(self:rawinput(p), p, frame)
		end
		return self
	end

	--- Stream-function which should be used in `for ... in stream` loops.
	-- @param[opt=1] number player  
	-- @return[1] function  Execution data of the returned function is listed below:
	-- @return[2] number  Player ID.
	-- @return[2] number  Frame number.
	-- @return[2] number  Input data.
	function Manager:stream(player)
		local it = { }
		local from, to = player or 1, player or (self.localplayers + self.remoteplayers)
		for p = 1, to do
			it[p] = inputs[p]
		end
		return function ()
			for p = from, to do
				if it[p].next and it[p].next.frame < self.timer then
					it[p] = it[p].next
					return p, it[p].frame, it[p].data
				end
			end
		end
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
	function Manager:press(button, player)
		player = player or 1
		self.buttons[player][button] = true
		self:saveinput(player)
	end

	--- Button released event.
	-- @param string button  Released button.
	-- @param number player  Player index.
	function Manager:release(button, player)
		player = player or 1
		self.buttons[player][button] = false
		self:saveinput(player)
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

return setmetatable(Manager, { __call = Manager.init })