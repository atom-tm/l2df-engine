local l2df = l2df
local ui = l2df.ui
local settings = l2df.settings
local i18n = l2df.i18n

local room = { }

	local fnt_menu = "menu_element"

	local list = ui.List(512, 32, {
			ui.Button(ui.Text(i18n("menu.versus"), fnt_menu), 0, 0):useMouse(true)
				:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
				:on("click", function () l2df.rooms:set("character_select") end),

			ui.Button(ui.Text(i18n("menu.story"), fnt_menu), 0, 64):useMouse(true)
				:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
				:on("click", function () l2df.rooms:set("myroom") end),

			ui.Button(ui.Text(i18n("menu.settings"), fnt_menu), 0, 128):useMouse(true)
				:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
				:on("click", function () l2df.rooms:set("settings") end),

			ui.Button(ui.Text(i18n("menu.exit"), fnt_menu), 0, 192):useMouse(true)
				:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
				:on("click", function () love.event.quit() end),
		})

		local test_image0 = ui.Image(ui.resource("interface_test00.png"),settings.global.width - 10,100)
		local test_image010 = ui.Image(ui.resource("interface_test01.png"),10,10,{w=150,h=150,x=4,y=1},4)
		local test_image011 = ui.Image(ui.resource("interface_test01.png"),settings.global.width / 2 + 75,250,{w=150,h=150,x=4,y=1},3)

		local test_text = ui.Text("That's Racist!", nil, 100, 100)


		-- :on("change", function (self, new, old)
		-- 	old.color[3] = 1
		-- 	new.color[3] = 0
		-- end)

	-- local btn = ui.Button("Hover me!", 280, 32, nil, nil, -32, 16, "sprites/UI/small.png", true)
	-- 		:on("update", function (self) if self.hover and not self.clicked then self:setText("Yeah, now click on me!") end end)
	-- 		:on("click", function (self) self:setText("You're a good boy!") end)

	room.nodes = {
		ui.Image("sprites/UI/background.png"),
		ui.Image("sprites/UI/logotype.png", 25, 25),
		list,
		test_image0,
		test_image010,
		test_image011,
		test_text,
	}

	function room:load()
		self.nodes[#self.nodes + 1] = ui.Text(i18n "menu.versus", fnt_menu, 825, 15)
		l2df.sound:setMusic("music/main.mp3")
		self.scenes = {
			l2df.image.Load("sprites/UI/MainMenu/1.png"),
			l2df.image.Load("sprites/UI/MainMenu/2.png"),
			l2df.image.Load("sprites/UI/MainMenu/3.png"),
		}
		self.scene = math.random(1, #self.scenes)

		self.opacity = 0.1
		self.opacity_change = 0.001
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

	function room:update()
		self.opacity = self.opacity + self.opacity_change
		if self.opacity > 0.3 or self.opacity < 0.1 then self.opacity_change = -self.opacity_change end
	end

	function room:draw()
		l2df.image.draw(self.scenes[self.scene], 0, 0, settings.gameHeight - 240, 0, 2)
	end

return room