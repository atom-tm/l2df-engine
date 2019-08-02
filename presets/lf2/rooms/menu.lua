local l2df = l2df
local ui = l2df.ui
local settings = l2df.settings
local i18n = l2df.i18n

local room = { opacity }

	local fnt_menu = "main_menu"

	local list = ui.List(512, 32, {
		ui.Button(ui.Text(i18n "menu.versus", fnt_menu), 0, 0):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () l2df.rooms:set("battle") end),

		ui.Button(ui.Text(i18n "menu.story", fnt_menu), 0, 64):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () l2df.rooms:set("myroom") end),

		ui.Button(ui.Text(i18n "menu.settings", fnt_menu), 0, 128):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () l2df.rooms:set("settings") end),

		ui.Button(ui.Text(i18n "menu.exit", fnt_menu), 0, 192):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () love.event.quit() end),
	})

	room.nodes = {
		ui.Image("sprites/UI/background.png"),
		ui.Image("sprites/UI/logotype.png", 25, 25),
		list,
	}

	function room:load()
		self.opacity = 1
		l2df.sound:setMusic("music/main.mp3")
		self.scenes = {
			l2df.image.load("sprites/UI/MainMenu/1.png"),
			l2df.image.load("sprites/UI/MainMenu/2.png"),
			l2df.image.load("sprites/UI/MainMenu/3.png"),
		}
		self.scene = math.random(1, #self.scenes)
	end

	function room:exit()
		for i = 1, #self.nodes do
			if self.nodes[i].stop then self.nodes[i]:stop() end
		end
	end

	function room:keypressed(key)
		if key == "f1" then
			l2df.rooms:set("settings")
		end
		if key == "escape" then
			love.event.quit()
		end
	end

	function room:update(dt)
		if self.opacity and self.opacity > 0 then
			self.opacity = self.opacity - 0.65 * dt
		end
	end

	function room:draw()
		l2df.image.draw(self.scenes[self.scene], 0, settings.gameHeight - 240)

		local ro, go, bo, ao = love.graphics.getColor()
		love.graphics.setColor(0,0,0,self.opacity)
		love.graphics.rectangle("fill", 0, 0, settings.global.width, settings.global.height)
		love.graphics.setColor(ro, go, bo, ao)
	end


return room