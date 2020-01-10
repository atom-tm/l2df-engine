local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
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

local Manager = { time = 0, buttons = { }, mapping = { }, keys = { }, keymap = { } }

	--- Init
	function Manager:init(keys)
		keys = keys or { }
		inputs = { }
		self.time = 0
		self.keys = { }
		self.keymap = { }
		for i = 1, #keys do
			self.keys[i] = { keys[i], bit(i) }
			self.keymap[keys[i]] = i
		end
	end

	--- Sync mappings with config
	function Manager:updateMappings(controls)
		self.mapping = { }
		for p = 1, #controls do
			inputs[p] = { data = 0, time = 0 }
			self.buttons[p] = { }
			for k, v in pairs(controls[p]) do
				if self.keymap[k] then
					self.mapping[v] = { k, p }
				end
			end
		end
	end

	--- Check if button is pressed
	-- @param string button  Pressed button
	-- @param number player  Player to check
	-- @return boolean
	function Manager:ispressed(button, player)
		local index = self.keymap[button]
		local input = inputs[player or 1]
		return index and input and hasbit(input.data, self.keys[index][2]) or false
	end

	--- Check if input data exists
	-- @param number data
	-- @param number player
	-- @return boolean
	function Manager:check(data, player)
		local input = inputs[player or 1]
		return input and hasbit(input.data, data) or false
	end

	--- Persist input
	function Manager:addinput(input, player, time)
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
		return self
	end

	--- Save input for local player
	function Manager:saveinput(player, time)
		return self:addinput(self:getinput(player), player, time)
	end

	--- Get input for local player
	-- @param number player
	-- @return number
	function Manager:getinput(player)
		local buttons = self.buttons[player or 1]
		if not buttons then return 0 end

		local input, kc = 0
		for i = 1, #self.keys do
			kc = self.keys[i]
			if buttons[kc[1]] then
				print(kc[1], kc[2])
				input = setbit(input, kc[2])
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