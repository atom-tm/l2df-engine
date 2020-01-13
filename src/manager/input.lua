--- Input manager
-- @classmod l2df.manager.input
-- @author Abelidze
-- @copyright Atom-TM 2020

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
		self.localplayers = 0
		self.remoteplayers = 0
		self.keys = { }
		self.keymap = { }
		self:reset()
		for i = 1, #keys do
			self.keys[i] = { keys[i], bit(i) }
			self.keymap[keys[i]] = i
		end
	end

	---
	function Manager:reset()
		self.time = 0
		self.remoteplayers = 0
		inputs = { }
		for p = 1, self.localplayers do
			self.buttons[p] = { }
			inputs[p] = { data = 0, time = 0 }
		end
	end

	---
	-- @return number
	function Manager:newRemotePlayer()
		self.remoteplayers = self.remoteplayers + 1
		inputs[self.localplayers + self.remoteplayers] = { data = 0, time = 0 }
		return self.localplayers + self.remoteplayers
	end

	--- Sync mappings with config
	function Manager:updateMappings(controls)
		self.mapping = { }
		self.localplayers = #controls
		for p = 1, self.localplayers do
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
	-- @param number player  Player to check or nil to check any local player
	-- @return boolean
	-- @return number
	function Manager:pressed(button, player)
		local index = self.keymap[button]
		if index then
			index = self.keys[index][2]
			local input = nil
			for i = player or 1, player or self.localplayers do
				input = inputs[i]
				if input and hasbit(input.data, index) then
					return true, i
				end
			end
		end
		return false
	end

	--- Check if input data exists
	-- @param number data
	-- @param number player
	-- @return boolean
	function Manager:check(data, player)
		local input = inputs[player or 1]
		return input and hasbit(input.data, data) or false
	end

	--- Get last saved input for specific player
	-- @param number player
	-- @return number
	function Manager:lastinput(player)
		local input = inputs[player or 1]
		return input and input.data or 0
	end

	--- Persist input
	-- @param number input
	-- @param number player
	-- @param number time
	-- @return InputManager
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
		if time <= self.time then
			inputs[player] = new
			self.time = time
		end
		return self
	end

	--- Save input for local player
	-- @param number player
	-- @param number time
	-- @return number
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
	function Manager:update(dt, islast)
		self.time = self.time + dt
		for i = 1, #inputs do
			local it = inputs[i]
			while it.prev and it.prev.time > self.time do
				it = it.prev
			end
			while it.next and it.next.time < self.time do
				if not islast then print('RESIM', it.data) end
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