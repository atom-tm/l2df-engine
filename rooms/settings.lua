local settings = {}

	settings.selected = 1
	settings.background_image = LoadImage("sprites/UI/background.png")
	settings_list = {}
	local opacity = 0.1
	local opacity_change = 0.0015
	local selected_size = selected_window_size
	

	function settings.load()

		setting = {}
		setting.id = 1
		setting.option = localization.settings.language
		function setting:action_left()
			localization_number = localization_number - 1
			if localization_number > 1 then
				localization_number = #localization_list
			end
			localization = require(localization_list[localization_number])
			setRoom(room.id)
		end
		function setting:action_right()
			localization_number = localization_number + 1
			if localization_number > #localization_list then
				localization_number = 1
			end
			localization = require(localization_list[localization_number])
			setRoom(room.id)
		end
		setting.status = localization.language
		settings_list[setting.id] = setting


		setting = {}
		setting.id = 2
		setting.option = localization.settings.effects
		function setting:action_left()
			if window.music_vol > 0 then
				window.music_vol = window.music_vol - 5
			end
			self.status = ""
			for i = 1, window.music_vol * 0.2 do
				self.status = self.status .. "I"
			end
		end
		function setting:action_right()
			if window.music_vol < 100 then
				window.music_vol = window.music_vol + 5
			end
			self.status = ""
			for i = 1, window.music_vol * 0.2 do
				self.status = self.status .. "I"
			end
		end
		setting.status = ""
		for i = 1, window.music_vol * 0.2 do
			setting.status = setting.status .. "I"
		end
		settings_list[setting.id] = setting


		setting = {}
		setting.id = 3
		setting.option = localization.settings.music
		function setting:action_left()
			if window.sound_vol > 0 then
				window.sound_vol = window.sound_vol - 5
			end
			self.status = ""
			for i = 1, window.sound_vol * 0.2 do
				self.status = self.status .. "I"
			end
		end
		function setting:action_right()
			if window.sound_vol < 100 then
				window.sound_vol = window.sound_vol + 5
			end
			self.status = ""
			for i = 1, window.sound_vol * 0.2 do
				self.status = self.status .. "I"
			end
		end
		setting.status = ""
		for i = 1, window.sound_vol * 0.2 do
			setting.status = setting.status .. "I"
		end
		settings_list[setting.id] = setting




		setting = {}
		setting.id = 4
		setting.option = localization.settings.fullscreen
		function setting:action_left()
			window.fullscreen = not window.fullscreen
			setFullscreen()
			if window.fullscreen == true then
				self.status = localization.settings.on
				settings_list[5].hidden = true
			else
				self.status = localization.settings.off
				settings_list[5].hidden = false
			end
		end
		function setting:action_right()
			window.fullscreen = not window.fullscreen
			setFullscreen()
			if window.fullscreen == true then
				self.status = localization.settings.on
				settings_list[5].hidden = true
			else
				self.status = localization.settings.off
				settings_list[5].hidden = false
			end
		end
		if window.fullscreen == true then
			setting.status = localization.settings.on
		else
			setting.status = localization.settings.off
		end
		settings_list[setting.id] = setting


		setting = {}
		setting.id = 5
		setting.option = localization.settings.window_size
		setting.status = window_sizes[selected_window_size].width.." x "..window_sizes[selected_window_size].height
		if window.fullscreen == true then
			setting.hidden = true
		end
		function setting:action_left()
			selected_size = selected_size - 1
			if selected_size < 1 then
				selected_size = #window_sizes
			end
			self.status = window_sizes[selected_size].width.." x "..window_sizes[selected_size].height
		end
		function setting:action_right()
			selected_size = selected_size + 1
			if selected_size > #window_sizes then
				selected_size = 1
			end
			self.status = window_sizes[selected_size].width.." x "..window_sizes[selected_size].height
		end
		function setting:action_click()
			selected_window_size = selected_size
			setWindowSize()
		end
		settings_list[setting.id] = setting


		setting = {}
		setting.id = 6
		setting.option = localization.settings.controls
		setting.action_click = function()
			setRoom(4)
		end
		settings_list[setting.id] = setting


		setting = {}
		setting.id = 7
		setting.option = localization.settings.back
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
			love.graphics.draw(settings.background_image,0,0,0,1,1)
			
			print(localization.settings.settings, 250, 50, nil, fonts.menu_head, 0, 300, 0, 0, 0, 1)

			local y_offset = 70
			local y_pos = 150
			for i = 1, #settings_list do
				if settings.selected == i then
					love.graphics.setColor(0,0,0, opacity)
					love.graphics.rectangle("fill", 260, y_pos - 15, 740, 70)
					love.graphics.setColor(1,1,1, 1)
				end
				local text_opacity = 1
				if settings_list[i].hidden == true then
				    text_opacity = 0.5
				end

				if settings_list[i].option ~= nil then
					print(settings_list[i].option, 300, y_pos, nil, fonts.menu, 0, 500, 0, 0, 0, text_opacity)
				end
				if settings_list[i].status ~= nil then
					print(settings_list[i].status, 800, y_pos, nil, fonts.menu, true, 300, 0, 0, 0, text_opacity)
				end
				y_pos = y_pos + y_offset
				love.graphics.setColor(1,1,1,1)
			end
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

		if button == "f3" then 
			if window.localization == "EN" then
				window.localization = "RU"
				localization = require "data.russian" 
			elseif window.localization == "RU" then
				window.localization = "EN"
				localization = require "data.english" 
			end
			setRoom(3)
		end
		
		if button == "escape" or button == control_settings[1].jump or button == control_settings[2].jump then
			setRoom(1)
		end

		save_settings()
	end

return settings