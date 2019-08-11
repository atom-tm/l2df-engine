local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Controller works only with l2df v1.0 and higher")

local Component = core.import "core.entities.component"
local input = core.import "input"

local Controller = Component:extend({
	controller = 0
})

	--- Check if button is pressed
	-- @param button, string  Pressed button
	-- @return boolean
	function Controller:pressed(button)
		return input:pressed(key)
	end

	--- Check if button's timer is executed
	-- @param button, string  Pressed button
	-- @return boolean
	function Controller:timer(button)
		return self.key_timer[button] > 0
	end

	--- Check if button's double_timer is executed
	-- @param button, string  Pressed button
	-- @return boolean
	function Controller:double_timer(button)
		return self.double_key_timer[button] > 0
	end

	--- Check if button's double_timer is ended
	-- @param button, string  Pressed button
	-- @return boolean
	function Controller:hit(button)
		return self.key_timer[button] == control.key_timer
	end

	--- Set controller for player
	function Controller:setController(id)
		self.controller = id
	end

	--- Remove controller from player
	function Controller:removeController()
		self.controller = 0
	end

	--- Process the keys and combos
	function Controller:keysCheck()
		local combo_len = #self.hit_code
		local i = 0
		for key in pairs(self.key_timer) do
			i = i + 1
			if self:hit(key) then self.hit_code = self.hit_code .. i end
		end

		local new_combo_len = #self.hit_code
		if new_combo_len > combo_len then
			self.hit_timer = control.combination_timer
			if new_combo_len > control.max_combo then
				self.hit_code = self.hit_code:sub(1 + new_combo_len - combo_len)
			end
		end
	end

	--- Start timers for pressed keys
	function Controller.keyPressed(button)
		for i = 1, #settings.controls do
			if control.players[i] then
				local k_timer = control.players[i].key_timer
				local dk_timer = control.players[i].double_key_timer

				for key in pairs(settings.controls[i]) do
					if button == settings.controls[i][key] then
						if k_timer[key] == 0 then
							k_timer[key] = control.key_timer
						end

						if dk_timer[key] == 0 then
							dk_timer[key] = control.key_double_timer_reverse
						elseif dk_timer[key] < 0 then
							dk_timer[key] = control.key_double_timer
						end
					end
				end
			end
		end
	end

	--- Update controller timers
	function Controller:update(dt)
		-- for i = 1, #settings.controls do
		-- 	if control.players[i] then
		-- 		local k_pressed = control.players[i].key_pressed
		-- 		local k_timer = control.players[i].key_timer
		-- 		local dk_timer = control.players[i].double_key_timer

		-- 		for key in pairs(settings.controls[i]) do

		-- 			if love.keyboard.isScancodeDown(settings.controls[i][key]) then
		-- 				k_pressed[key] = 1
		-- 			elseif k_pressed[key] > 0 then
		-- 				k_pressed[key] = k_pressed[key] - 1
		-- 			end

		-- 			if k_timer[key] > 0 then
		-- 				k_timer[key] = k_timer[key] - 1
		-- 			end

		-- 			if abs(dk_timer[key]) > 0 then
		-- 				dk_timer[key] = dk_timer[key] - helper.sign(dk_timer[key])
		-- 			end

		-- 		end
		-- 	end
		-- end
	end

return Controller