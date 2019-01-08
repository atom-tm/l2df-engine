local room = {}

	function room:Load()
		self.selected = 1
		self.opacity = 0.1
		self.opacity_change = 0.0015
		self.selected_size = settings.window.selectedSize
		self.list = {}

		self.background_image = image.Load("sprites/UI/background.png", nil, "linear")



		local setting = {
			id = 1,
			option = locale.settings.language,
			status = locale.language
		}
		function setting:action_left()
			local local_id = loc.id - 1
			if local_id < 1 then local_id = #loc.list end
			loc:Set(local_id)
			rooms:Reload()
		end
		function setting:action_right()
			local local_id = loc.id + 1
			if local_id > #loc.list then local_id = 1 end
			loc:Set(local_id)
			rooms:Reload()
		end
		self.list[setting.id] = setting



		local setting = {
			id = 2,
			option = locale.settings.music,
			status = ""
		}
		function setting:action_left()
			if settings.window.music_vol > 0 then settings.window.music_vol = settings.window.music_vol - 5 end
			self.status = ""
			for i = 1, settings.window.music_vol * 0.2 do self.status = self.status .. "I" end
		end
		function setting:action_right()
			if settings.window.music_vol < 100 then settings.window.music_vol = settings.window.music_vol + 5 end
			self.status = ""
			for i = 1, settings.window.music_vol * 0.2 do self.status = self.status .. "I" end
		end
		for i = 1, settings.window.music_vol * 0.2 do
			setting.status = setting.status .. "I"
		end
		self.list[setting.id] = setting



		local setting = {
			id = 3,
			option = locale.settings.effects,
			status = ""
		}
		function setting:action_left()
			if settings.window.sound_vol > 0 then settings.window.sound_vol = settings.window.sound_vol - 5 end
			self.status = ""
			for i = 1, settings.window.sound_vol * 0.2 do self.status = self.status .. "I" end
		end
		function setting:action_right()
			if settings.window.sound_vol < 100 then settings.window.sound_vol = settings.window.sound_vol + 5 end
			self.status = ""
			for i = 1, settings.window.sound_vol * 0.2 do self.status = self.status .. "I" end
		end
		for i = 1, settings.window.sound_vol * 0.2 do
			setting.status = setting.status .. "I"
		end
		self.list[setting.id] = setting


		local setting = {
			id = 4,
			option = locale.settings.fullscreen
		}
		function setting:action_left()
			settings.window.fullscreen = not settings.window.fullscreen
			func.SetWindowSize()
			if settings.window.fullscreen == true then
				self.status = locale.settings.on
			else
				self.status = locale.settings.off
			end
		end
		function setting:action_right()
			settings.window.fullscreen = not settings.window.fullscreen
			func.SetWindowSize()
			if settings.window.fullscreen == true then
				self.status = locale.settings.on
			else
				self.status = locale.settings.off
			end
		end
		if settings.window.fullscreen == true then setting.status = locale.settings.on
		else setting.status = locale.settings.off end
		self.list[setting.id] = setting


		local setting = {
			id = 5,
			option = locale.settings.window_size,
			status = settings.windowSizes[settings.window.selectedSize].width.." x "..settings.windowSizes[settings.window.selectedSize].height
		}
		function setting:action_left()
			room.selected_size = room.selected_size - 1
			if room.selected_size < 1 then room.selected_size = #settings.windowSizes end
			self.status = settings.windowSizes[room.selected_size].width.." x "..settings.windowSizes[room.selected_size].height
		end
		function setting:action_right()
			room.selected_size = room.selected_size + 1
			if room.selected_size > #settings.windowSizes then room.selected_size = 1 end
			self.status = settings.windowSizes[room.selected_size].width.." x "..settings.windowSizes[room.selected_size].height
		end
		function setting:action_click()
			settings.window.selectedSize = room.selected_size
			func.SetWindowSize()
		end
		self.list[setting.id] = setting


		local setting = {
			id = 6,
			option = locale.settings.controls
		}
		function setting:action_click ()
			rooms:Set("controls")
		end
		self.list[setting.id] = setting


		local setting = {
			id = 7,
			option = locale.settings.back
		}
		function setting:action_click()
			rooms:Set("main_menu")
		end
		self.list[setting.id] = setting

	end

	function room:Update()
		self.opacity = self.opacity + self.opacity_change
		if self.opacity < 0.05 or self.opacity > 0.15 then
			self.opacity_change = -self.opacity_change
		end
		if settings.window.fullscreen then room.list[5].hidden = true
		else room.list[5].hidden = false end
	end

	function room:Draw()
		image.draw(self.background_image,0,0,0)
		font.print(locale.settings.settings, 250, 50, nil, font.list.setting_header, 0, 300, 0, 0, 0, 1)
		local y_offset = 70
		local y_pos = 150
			
		for i = 1, #self.list do
			if self.selected == i then
				love.graphics.setColor(0,0,0, self.opacity)
				love.graphics.rectangle("fill", 260, y_pos - 15, 740, 70)
				love.graphics.setColor(1,1,1, 1)
			end
			local text_opacity = 1
			if self.list[i].hidden == true then
				text_opacity = 0.5
			end

			if self.list[i].option ~= nil then
				font.print(self.list[i].option, 300, y_pos, nil, font.list.setting_element, 0, 500, 0, 0, 0, text_opacity)
			end

			if self.list[i].status ~= nil then
				font.print(self.list[i].status, 800, y_pos, nil, font.list.setting_element, true, 300, 0, 0, 0, text_opacity)
			end

			y_pos = y_pos + y_offset
			love.graphics.setColor(1,1,1,1)
		end
	end


	function room:Keypressed(key)

		if key == settings.controls[1].up or key == settings.controls[2].up then
			self.selected = self.selected - 1
			if self.selected < 1 then self.selected = #self.list end
			local hidden_exit = true
			while hidden_exit do 
				if self.list[self.selected].hidden then
					self.selected = self.selected - 1
					if self.selected < 1 then self.selected = #self.list end
				else hidden_exit = false end
			end
		end

		if key == settings.controls[1].down or key == settings.controls[2].down then
			self.selected = self.selected + 1
			if self.selected > #self.list then self.selected = 1 end
			local hidden_exit = true
			while hidden_exit do 
				if self.list[self.selected].hidden then
					self.selected = self.selected + 1
					if self.selected > #self.list then self.selected = 1 end
				else hidden_exit = false end
			end
		end

		if key == settings.controls[1].attack or key == settings.controls[2].attack then
			if self.list[self.selected].action_click ~= nil then
				self.list[self.selected]:action_click()
			end
		end

		if key == settings.controls[1].left or key == settings.controls[2].left then
			if self.list[self.selected].action_left ~= nil then
				self.list[self.selected]:action_left()
			end
		end

		if key == settings.controls[1].right or key == settings.controls[2].right then
			if self.list[self.selected].action_right ~= nil then
				self.list[self.selected]:action_right()
			end
		end

		if key == "f1" then rooms:Set("controls") end
		
		if key == "escape" or key == settings.controls[1].jump or key == settings.controls[2].jump then
			rooms:Set("main_menu")
		end
    	settings:Save()
	end

return room