local room = {}
	--[[
	function room:load()
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

		self.selected_mode = 1
		self.modes = {
			{
				text = locale.main_menu.versus,
				action = function ()
					rooms:set("character_select")
				end
			},
			{
				text = locale.main_menu.story,
				action = function ()
					-- ignore
				end
			},
			{
				text = loc.text.main_menu.settings,
				action = function ()
					rooms:set("settings")
				end
			},
			{
				text = locale.main_menu.exit,
				action = function ()
					love.event.quit( )
				end
			},
		}

		sounds.setMusic("music/main.mp3")
	end

	function room:update()
		self.opacity = self.opacity + self.opacity_change
		if self.opacity > 0.3 or self.opacity < 0.1 then self.opacity_change = -self.opacity_change end
	end

	function room:draw()
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

	function room:keypressed(key)
		local modes = #self.modes
		for _, control in pairs(settings.controls) do
			if key == control.up then 
				self.selected_mode = self.selected_mode < 1 and (self.selected_mode - 1) or modes
				return
			elseif key == control.down then 
				self.selected_mode = self.selected_mode > modes and (self.selected_mode + 1) or 1
				return
			elseif key == control.attack then 
				self.modes[self.selected_mode].action()
				return
			end
		end
		if key == "f1" then rooms:set("settings") end
	end
]]
return room