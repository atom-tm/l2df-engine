local control = {}
	control.players = {}


	control.key_timer = 7
	control.key_double_timer_reverse = -15
	control.key_double_timer = 7
	control.max_combo = 3
	control.combination_timer = control.key_timer * control.max_combo


	function control:pressed(button)
		if self.key_pressed[button] > 0 then return true
		else return false end
	end
	function control:timer(button)
		if self.key_timer[button] > 0 then return true
		else return false end
	end
	function control:double_timer(button)
		if self.double_key_timer[button] > 0 then return true
		else return false end
	end
	function control:hit(button)
		if self.key_timer[button] == control.key_timer then return true
		else return false end
	end


	function control:setController()
		if self.controller > 0 then
			control.players[self.controller] = self
		end
	end
	function control:removeController()
		if self.controller > 0 then
			control.players[self.controller] = nil
		end
	end

	function control:keysCheck()
		local code_lenght = #self.hit_code
		local i = 0
		for key in pairs(self.key_timer) do
			i = i + 1
			if self:hit(key) then self.hit_code = self.hit_code .. i end
		end
		if #self.hit_code > code_lenght then
			self.hit_timer = control.combination_timer
			if #self.hit_code > control.max_combo then
				self.hit_code = self.hit_code:sub(1 + #self.hit_code - code_lenght)
			end
		end
	end


	
	function control.keyPressed(button)
		for i = 1, #settings.controls do
			for key in pairs(settings.controls[i]) do
				if control.players[i] ~= nil then
					if button == settings.controls[i][key] then
						if control.players[i].key_timer[key] == 0 then
							control.players[i].key_timer[key] = control.key_timer
						end
						if control.players[i].double_key_timer[key] == 0 then
							control.players[i].double_key_timer[key] = control.key_double_timer_reverse
						elseif control.players[i].double_key_timer[key] < 0 then
							control.players[i].double_key_timer[key] = control.key_double_timer
						end
					end
				end
			end
		end
	end
	


	function control.Update()
		for i = 1, #settings.controls do
			for key in pairs(settings.controls[i]) do
				if control.players[i] ~= nil then
					if love.keyboard.isScancodeDown(settings.controls[i][key]) then
						control.players[i].key_pressed[key] = 1
					else
						if control.players[i].key_pressed[key] > 0 then
							control.players[i].key_pressed[key] = control.players[i].key_pressed[key] - 1
						end
					end
					if control.players[i].key_timer[key] > 0 then
						control.players[i].key_timer[key] = control.players[i].key_timer[key] - 1
					end
					if control.players[i].double_key_timer[key] > 0 then
						control.players[i].double_key_timer[key] = control.players[i].double_key_timer[key] - 1
					elseif control.players[i].double_key_timer[key] < 0 then
						control.players[i].double_key_timer[key] = control.players[i].double_key_timer[key] + 1
					end
				end
			end
		end
	end



return control