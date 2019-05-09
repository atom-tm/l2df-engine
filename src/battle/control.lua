local control = { }
	-- TODO: change the whole combo system, it's pretty sluggish

	local abs = math.abs

	control.players = { }
	control.key_timer = 7
	control.key_double_timer_reverse = -15
	control.key_double_timer = 7
	control.max_combo = 3
	control.combination_timer = control.key_timer * control.max_combo


	--- Check if button is pressed
	-- @param button, string  Pressed button
	-- @return boolean
	function control:pressed(button)
		return self.key_pressed[button] > 0
	end

	--- Check if button's timer is executed
	-- @param button, string  Pressed button
	-- @return boolean
	function control:timer(button)
		return self.key_timer[button] > 0
	end

	--- Check if button's double_timer is executed
	-- @param button, string  Pressed button
	-- @return boolean
	function control:double_timer(button)
		return self.double_key_timer[button] > 0
	end

	--- Check if button's double_timer is ended
	-- @param button, string  Pressed button
	-- @return boolean
	function control:hit(button)
		return self.key_timer[button] == control.key_timer
	end

	--- Set controller for player
	function control:setController()
		if self.controller > 0 then
			control.players[self.controller] = self
		end
	end

	--- Remove controller from player
	function control:removeController()
		if self.controller > 0 then
			control.players[self.controller] = nil
		end
	end

	--- Process the keys and combos
	function control:keysCheck()
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
	function control.keyPressed(button)
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
	function control.Update()
		for i = 1, #settings.controls do
			if control.players[i] then
				local k_pressed = control.players[i].key_pressed
				local k_timer = control.players[i].key_timer
				local dk_timer = control.players[i].double_key_timer

				for key in pairs(settings.controls[i]) do

					if love.keyboard.isScancodeDown(settings.controls[i][key]) then
						k_pressed[key] = 1
					elseif k_pressed[key] > 0 then
						k_pressed[key] = k_pressed[key] - 1
					end

					if k_timer[key] > 0 then
						k_timer[key] = k_timer[key] - 1
					end

					if abs(dk_timer[key]) > 0 then
						dk_timer[key] = dk_timer[key] - helper.sign(dk_timer[key])
					end

				end
			end
		end
	end

return control