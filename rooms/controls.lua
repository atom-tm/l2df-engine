local room = {}

	function room:Load()
		
		self.list = {}
		self.setup_mode = false

		self.p1_opt = 1
		self.p2_opt = 1
		self.player = 0

		self.opacity = 0.1
		self.opacity_change = 0.0015

		local setting = {}
		setting.massive = "up"
		setting.option = locale.controls.up
		setting.p1 = settings.controls[1].up
		setting.p2 = settings.controls[2].up
		table.insert(self.list, setting)

		local setting = {}
		setting.massive = "down"
		setting.option = locale.controls.down
		setting.p1 = settings.controls[1].down
		setting.p2 = settings.controls[2].down
		table.insert(self.list, setting)

		local setting = {}
		setting.massive = "left"
		setting.option = locale.controls.left
		setting.p1 = settings.controls[1].left
		setting.p2 = settings.controls[2].left
		table.insert(self.list, setting)

		local setting = {}
		setting.massive = "right"
		setting.option = locale.controls.right
		setting.p1 = settings.controls[1].right
		setting.p2 = settings.controls[2].right
		table.insert(self.list, setting)

		local setting = {}
		setting.massive = "attack"
		setting.option = locale.controls.attack
		setting.p1 = settings.controls[1].attack
		setting.p2 = settings.controls[2].attack
		table.insert(self.list, setting)

		local setting = {}
		setting.massive = "jump"
		setting.option = locale.controls.jump
		setting.p1 = settings.controls[1].jump
		setting.p2 = settings.controls[2].jump
		table.insert(self.list, setting)

		local setting = {}
		setting.massive = "defend"
		setting.option = locale.controls.defend
		setting.p1 = settings.controls[1].defend
		setting.p2 = settings.controls[2].defend
		table.insert(self.list, setting)

		local setting = {}
		setting.massive = "special1"
		setting.option = locale.controls.special1
		setting.p1 = settings.controls[1].special1
		setting.p2 = settings.controls[2].special1
		table.insert(self.list, setting)

		self.background_image = image.Load("sprites/UI/background.png", nil, "linear")
	end

	function room:Update()
		self.opacity = self.opacity + self.opacity_change
		if self.opacity < 0.05 or self.opacity > 0.15 then
			self.opacity_change = -self.opacity_change
		end
	end


	function room:Draw()
		image.draw(self.background_image,0,0,0)

		font.print(locale.controls.controls, 250, 50, nil, font.list.setting_header, 0, 300, 0, 0, 0, 1)
		font.print(locale.controls.info, 0, 645, "center", font.list.setting_comment, 0, 1280, 0, 0, 0, self.opacity * 3 + 0.4)
		font.print(locale.controls.p1, 550, 70, nil, font.list.setting_element, 0, 300, 0, 0, 0, 1)
		font.print(locale.controls.p2, 830, 70, nil, font.list.setting_element, 0, 300, 0, 0, 0, 1)
			

		local y_offset = 57
		local y_pos = 155
		for i = 1, #self.list do
			font.print(self.list[i].option, 190, y_pos, "right", font.list.setting_element, 0, 205, 0, 0, 0, 1)
			if self.setup_mode and self.player == 1 and self.p1_opt == i then
				love.graphics.setColor(0,0,0, self.opacity)
				love.graphics.rectangle("fill", 550, y_pos - 5, 170, 55)
				love.graphics.setColor(1,1,1,1)
				font.print(self.list[i].p1, 550, y_pos, "center", font.list.setting_element, 0, 170, 1, 1, 1, 1)
			else
				font.print(self.list[i].p1, 550, y_pos, "center", font.list.setting_element, 0, 170, 0, 0, 0, 1)
			end
			if self.setup_mode and self.player == 2 and self.p2_opt == i then
				love.graphics.setColor(0,0,0, self.opacity)
				love.graphics.rectangle("fill", 830, y_pos - 5, 170, 55)
				love.graphics.setColor(1,1,1,1)
				font.print(self.list[i].p2, 830, y_pos, "center", font.list.setting_element, 0, 170, 1, 1, 1, 1)
			else
				font.print(self.list[i].p2, 830, y_pos, "center", font.list.setting_element, 0, 170, 0, 0, 0, 1)
			end

			y_pos = y_pos + y_offset
			love.graphics.setColor(1,1,1,1)
		end
	end

	function room:Keypressed (key)
		if self.setup_mode then
			if self.player == 1 then
				settings.controls[1][self.list[self.p1_opt].massive] = key
				self.list[self.p1_opt].p1 = key
				self.p1_opt = self.p1_opt + 1
			elseif self.player == 2 then
				settings.controls[2][self.list[self.p2_opt].massive] = key
				self.list[self.p2_opt].p2 = key
				self.p2_opt = self.p2_opt + 1
			end
			if self.p1_opt > 8 or self.p2_opt > 8 then
				settings:Save()
				rooms:Reload()
			end
		else
			if key == settings.controls[1].jump or key == settings.controls[2].jump or key == "escape" then
				rooms:Set("settings")
			end
			
			if key == "f1" then
				self.setup_mode = true
				self.player = 1
				self.p1_opt = 1
			end

			if key == "f2" then
				self.setup_mode = true
				self.player = 2
				self.p1_opt = 2
			end   
		end
	end
return room