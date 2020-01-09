local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'InputManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local inputs = { }

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

local Manager = { time = 0, buttons = { }, controls = { }, mapping = { }, keys = { }, keymap = { } }

	--- Init
	function Manager:init(keys)
		keys = keys or { }
		inputs = { }
		self.time = 0
		self.keys = { }
		self.keymap = { }
		for i = 1, #keys do
			self.keys[i] = { k, bit(i) }
			self.keymap[k] = i
		end
	end

	--- Sync mappings with config
	function Manager:updateMappings(controls)
		self.mapping = { }
		self.controls = controls or { }
		for p = 1, #self.controls do
			inputs[p] = { data = 0, time = 0 }
			self.buttons[p] = { }
			for k, v in pairs(self.controls[p]) do
				self.mapping[v] = { k, p }
			end
		end
	end

	--- Check if button is pressed
	-- @param string button  Pressed button
	-- @param number player  Player to check
	-- @return boolean
	function Manager:pressed(button, player)
		local controls = self.buttons[player or 1]
		return controls[button] and controls[button] > 0
	end

	--- Persist input
	function Manager:addinput(input, time, player)
		player = player or 1
		time = time or self.time
		local left = inputs[player]
		local right = left and left.next
		if time < self.time then
			while left and left.time > time do
				right = left
				left = left.prev
			end
		else
			while left and left.next and left.next.time < time do
				left = left.next
			end
			right = left and left.next
		end
		local new = {
			prev = left,
			next = right,
			time = time,
			data = input
		}
		if left then left.next = new end
		if right then right.prev = new end
		if time < self.time then
			inputs[player] = new
			self.time = time
		end
	end

	--- Get input for local player
	function Manager:getinput(player)
		player = player or 1
		local buttons = self.buttons[player]
		if not buttons then return 0 end

		local input, key, code = 0
		for i = 1, #self.keys do
			key, code = self.keys[i]
			if buttons[key] then
				setbit(input, code)
			end
		end
		return input
	end

	--- Button pressed event
	-- @param string button  Pressed button
	-- @param number player  Player index
	function Manager:press(button, player)
		player = player or 1
		self.buttons[player][button] = true
	end

	--- Button released event
	-- @param string button  Released button
	-- @param number player  Player index
	function Manager:release(button, player)
		player = player or 1
		self.buttons[player][button] = false
	end

	--- Hook for update
	function Manager:update(dt)
		self.time = self.time + dt
		for i = 1, #inputs do
			local it = inputs[i]
			while it.next and it.next.time < self.time do
				it = it.next
			end
			inputs[i] = it
		end
	end

	--- Hook for love.keypressed
	function Manager:keypressed(key)
		local map = self.mapping[key]
		if map then
			self:press(map[1], map[2])
		end
	end

	--- Hook for love.keyreleased
	function Manager:keyreleased(key)
		local map = self.mapping[key]
		if map then
			self:release(map[1], map[2])
		end
	end

return Manager