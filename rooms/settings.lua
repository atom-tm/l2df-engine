local settings = {}

	settings.selected = 1
	settings.background_image = LoadImage("sprites/UI/background.png")
	settings_list = {}
	local opacity = 0.1
	local opacity_change = 0.0015
	

	function settings.load()
		setting = {}
		setting.id = 1
		setting.option = "effects"
		function setting:action_left()
			if window.music_vol > 0 then
				window.music_vol = window.music_vol - 10
			end
			self.status = ""
			for i = 1, window.music_vol * 0.1 do
				self.status = self.status .. "i"
			end
		end
		function setting:action_right()
			if window.music_vol < 100 then
				window.music_vol = window.music_vol + 10
			end
			self.status = ""
			for i = 1, window.music_vol * 0.1 do
				self.status = self.status .. "i"
			end
		end
		setting.status = ""
		for i = 1, window.music_vol * 0.1 do
			setting.status = setting.status .. "i"
		end
		settings_list[setting.id] = setting


		setting = {}
		setting.id = 2
		setting.option = "music"
		function setting:action_left()
			if window.sound_vol > 0 then
				window.sound_vol = window.sound_vol - 10
			end
			self.status = ""
			for i = 1, window.sound_vol * 0.1 do
				self.status = self.status .. "i"
			end
		end
		function setting:action_right()
			if window.sound_vol < 100 then
				window.sound_vol = window.sound_vol + 10
			end
			self.status = ""
			for i = 1, window.sound_vol * 0.1 do
				self.status = self.status .. "i"
			end
		end
		setting.status = ""
		for i = 1, window.sound_vol * 0.1 do
			setting.status = setting.status .. "i"
		end
		settings_list[setting.id] = setting




		setting = {}
		setting.id = 3
		setting.option = "fullscreen"
		function setting:action_left()
			fullscreen = not fullscreen
			if fullscreen == true then
				self.status = "on"
				settings_list[4].hidden = true
			else
				self.status = "off"
				settings_list[4].hidden = false
			end
		end
		function setting:action_right()
			fullscreen = not fullscreen
			if fullscreen == true then
				self.status = "on"
				settings_list[4].hidden = true
			else
				self.status = "off"
				settings_list[4].hidden = false
			end
		end
		if fullscreen == true then
			setting.status = "on"
		else
			setting.status = "off"
		end
		settings_list[setting.id] = setting


		setting = {}
		setting.id = 4
		setting.option = "window size"
		setting.status = "1280 x 720"
		if fullscreen == true then
			setting.hidden = true
		end
		settings_list[setting.id] = setting


		setting = {}
		setting.id = 5
		setting.option = "controls (f1)"
		setting.action_click = function()
			setRoom(4)
		end
		settings_list[setting.id] = setting


		setting = {}
		setting.id = 6
		setting.option = "back"
		setting.action_click = function()
			setRoom(1)
		end
		settings_list[setting.id] = setting

	end

	function settings.update()
		if opacity < 0.05 or opacity > 0.15 then
			opacity_change = -opacity_change
		end
		opacity = opacity + opacity_change
	end

	function settings.draw()
		camera:draw(function(l,t,w,h)
			love.graphics.draw(settings.background_image,0,0,0,1,1)
			print("settings", 250, 50, 0, 1)
			local y_offset = 70
			local y_pos = 200
			for i = 1, #settings_list do
				if settings.selected == i then
					love.graphics.setColor(0,0,0, opacity)
					love.graphics.rectangle("fill", 280, y_pos - 10, 720, 70)
					love.graphics.setColor(1,1,1, 1)
				end

				if settings_list[i].hidden ~= true then
				    love.graphics.setColor(1,1,1,1)
				else
					love.graphics.setColor(1,1,1,0.3)
				end

				if settings_list[i].option ~= nil then
					print(settings_list[i].option, 300, y_pos, 0, 0.9)
				end
				if settings_list[i].status ~= nil then
					print(settings_list[i].status, 800, y_pos, 1, 0.9)
				end
				y_pos = y_pos + y_offset
				love.graphics.setColor(1,1,1,1)
			end
			love.graphics.print(settings.background_image:getWidth(),10,10)
			love.graphics.print(settings.background_image:getHeight(),10,30)
			love.graphics.print(string.byte("(",1),10,50)
			love.graphics.print(string.byte(")",1),10,70)
		end)
	end


	function settings.keypressed( button, scancode, isrepeat )
		
		if button == control_settings[1].up or button == control_settings[2].up then
			if settings.selected <= 1 then settings.selected = #settings_list
			else settings.selected = settings.selected - 1 end
			local exit = true
			while exit do
				if settings_list[settings.selected].hidden == true then
					if settings.selected <= 1 then
						settings.selected = #settings_list
					else settings.selected = settings.selected - 1 end
				else exit = false end
			end
		end

		if button == control_settings[1].down or button == control_settings[2].down then
			if settings.selected >= #settings_list then settings.selected = 1
			else settings.selected = settings.selected + 1 end
			local exit = true
			while exit do
				if settings_list[settings.selected].hidden == true then
					if settings.selected >= #settings_list then
						settings.selected = 1
					else settings.selected = settings.selected + 1 end
				else exit = false end
			end
		end

		if button == control_settings[1].attack or button == control_settings[2].attack then
			if settings_list[settings.selected].action_click ~= nil then
				settings_list[settings.selected]:action_click()
			end
		end
		
		if button == control_settings[1].left or button == control_settings[2].left then
			if settings_list[settings.selected].action_left ~= nil then
				settings_list[settings.selected]:action_left()
			end
		end

		if button == control_settings[1].right or button == control_settings[2].right then
			if settings_list[settings.selected].action_right ~= nil then
				settings_list[settings.selected]:action_right()
			end
		end

		if button == "f1" then setRoom(4) end
		
		if button == "escape" or button == control_settings[1].jump or button == control_settings[2].jump then
			setRoom(1)
		end
	end

return settings