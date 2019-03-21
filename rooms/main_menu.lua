local room = {}

	room.selected_mode = 1

	function room:Load()
		self.opacity = 0.1
		self.opacity_change = 0.001
		self.background_image = image.Load("sprites/UI/background.png", nil, "linear")
		self.logotype_image = image.Load("sprites/UI/logotype.png", nil, "linear")
		self.scenes = {
			image.Load("sprites/UI/MainMenu/1.png"),
			image.Load("sprites/UI/MainMenu/2.png"),
			image.Load("sprites/UI/MainMenu/3.png"),
		}
		self.scene = math.random(1, #self.scenes)

		self.modes = {
			{
				text = locale.main_menu.versus,
				action = function ()
					rooms:Set("character_select")
				end
			},
			{
				text = locale.main_menu.story,
				action = function ()
					
				end
			},
			{
				text = loc.text.main_menu.settings,
				action = function ()
					rooms:Set("settings")
				end
			},
			{
				text = locale.main_menu.exit,
				action = function ()
					love.event.quit( )
				end
			},
		}

	end

	function room:Update()
		self.opacity = self.opacity + self.opacity_change
		if self.opacity > 0.3 or self.opacity < 0.1 then self.opacity_change = -self.opacity_change end
	end

	function room:Draw()
		image.draw(self.background_image,0,0,0)
		image.draw(self.logotype_image,0,420,25)
		image.draw(self.scenes[self.scene],0,0,settings.gameHeight - 240, 0, 2)

		for i = 1, #self.modes do
			if i == self.selected_mode then
				love.graphics.setColor(0, 0, 0, .2 + self.opacity)
				love.graphics.rectangle("fill", settings.gameWidth / 2 - 150, 370 + 65 * i, 300, 65)
				love.graphics.setColor(1, 1, 1, 1)
			end
			font.print(self.modes[i].text, settings.gameWidth / 2 - 250, 370 + 65 * i, "center", font.list.menu_element, nil, 500)
		end
	end

	function room:Keypressed(key)
		if key == settings.controls[1].up or key == settings.controls[2].up then 
			self.selected_mode = self.selected_mode - 1
			if self.selected_mode < 1 then
				self.selected_mode = #self.modes
			end
		end
		if key == settings.controls[1].down or key == settings.controls[2].down then 
			self.selected_mode = self.selected_mode + 1
			if self.selected_mode > #self.modes then
				self.selected_mode = 1
			end
		end
		if key == settings.controls[1].attack or key == settings.controls[2].attack then 
			self.modes[self.selected_mode].action()
		end
		if key == "f1" then rooms:Set("settings") end
	end

return room