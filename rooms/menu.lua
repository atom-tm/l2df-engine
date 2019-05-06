local l2df = l2df
local ui = l2df.ui
local settings = l2df.settings

local room = { }

	local fnt_menu = l2df.font.list.menu_element

	local list = ui.List(32, 32, {
			ui.Button(ui.Text("menu.versus", fnt_menu), 0, 0)
				:on("update", function (self) self.text.color[3] = self.hover and 0 or 1 end)
				:on("click", function () l2df.i18n:setLocale("ru") end),

			ui.Button(ui.Text("menu.story", fnt_menu), 0, 64)
				:on("update", function (self) self.text.color[3] = self.hover and 0 or 1 end)
				:on("click", function () l2df.i18n:setLocale("en") end),

			ui.Button(ui.Text("menu.settings", fnt_menu), 0, 128)
				:on("update", function (self) self.text.color[3] = self.hover and 0 or 1 end)
				:on("click", function () l2df.rooms:set("settings") end),

			ui.Button(ui.Text("menu.exit", fnt_menu), 0, 192, nil, nil, 0, 0, nil, true)
				:on("update", function (self) self.text.color[3] = self.hover and 0 or 1 end)
				:on("click", function () love.event.quit() end),
		})
		-- :on("change", function (self, new, old)
		-- 	old.color[3] = 1
		-- 	new.color[3] = 0
		-- end)

	local btn = ui.Button("Hover me!", 280, 32, nil, nil, -32, 16, "sprites/UI/small.png", true)
			:on("update", function (self) if self.hover and not self.clicked then self:setText("Yeah, now click on me!") end end)
			:on("click", function (self) self:setText("You're a good boy!") end)

	room.nodes = {
		ui.Image("sprites/UI/background.png"),
		ui.Image("sprites/UI/logotype.png"),
		list,
		btn,
	}

	function room:load()
		l2df.sound:setMusic("music/main.mp3")
		self.scenes = {
			l2df.image.Load("sprites/UI/MainMenu/1.png"),
			l2df.image.Load("sprites/UI/MainMenu/2.png"),
			l2df.image.Load("sprites/UI/MainMenu/3.png"),
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
	end

	-- function room:update()
	-- 	-- self.opacity = self.opacity + self.opacity_change
	-- 	-- if self.opacity > 0.3 or self.opacity < 0.1 then self.opacity_change = -self.opacity_change end
	-- end

	function room:draw()
		l2df.image.draw(self.scenes[self.scene], 0, 0, settings.gameHeight - 240, 0, 2)
	end

return room

	--[[
	function room:load()
		print("hello!!!!")
	end

	function room:update()
		for i = 1, #self.elements do
			self.elements[i]:update()
		end
	end

	function room:draw()
		for i = 1, #self.elements do
			self.elements[i]:draw()
		end
	end

	function room:keypressed()
		
	end

	function room:exit()
		for i = 1, #self.elements do
			if self.elements[i].stop then self.elements[i]:stop() end
		end
	end

return room

	--[[
	function room:load()
		self.opacity = 0.1
		self.opacity_change = 0.001
		self.background_image = image.Load("sprites/UI/background.png", nil, "linear")
		self.logotype_image = image.Load("sprites/UI/logotype.png", nil, "linear")

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
	end
]]