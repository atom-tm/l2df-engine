local core = l2df
assert(type(core) == "table" and core.version >= 1.0, "Input works only with l2df v1.0 and higher")
assert(type(love) == "table", "Input works only under love2d's environment")

local settings = core.import "settings"

local hook = helper.hook

local input = { }

	input.buttons = { }
	input.double = { }
	input.controls = { }
	input.mapping = { }

	--- Init input system
	function input:init()
		hook(love, "keypressed", self.keypressed, self)
		hook(love, "keyreleased", self.keypressed, self)
	end

	--- Check if button is pressed
	-- @param button, string  Pressed button
	-- @param player, number  Player to check
	-- @return boolean
	function input:pressed(button, player)
		player = player or 1
		return self.buttons[player][button] > 0
	end

	--- Button pressed event
	-- @param button, string  Pressed button
	-- @param player, number  Player index
	function input:press(button, player)
		player = player or 1
		self.buttons[player][button] = 1
	end

	--- Button released event
	-- @param button, string  Released button
	-- @param player, number  Player index
	function input:release(button, player)
		player = player or 1
		self.buttons[player][button] = 0
	end

	--- Sync mappings with settings
	function input:updateMappings()
		self.mapping = { }
		self.controls = settings.controls
		for i = 1, #self.controls do
			self.buttons[i] = { }
			for k, v in pairs(self.controls[i]) do
				self.mapping[v] = { k, i }
			end
		end
	end

	--- Hook for love.keypressed
	function input:keypressed(key)
		if self.controls ~= settings.controls then
			self:updateMappings()
		end
		local map = self.mapping[key]
		if map then
			self:press(map[1], map[2])
		end
	end

	--- Hook for love.keyreleased
	function input:keyreleased(key)
		if self.mapping[key] then
			local map = self.mapping[key]
			self:release(map[1], map[2])
		end
	end

return input