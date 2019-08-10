local core = l2df
local ui = core.ui
local settings = core.settings
local i18n = core.i18n
local media = core.import "media"
local Room = core.import "rooms.room"

local room = Room:extend()

	local fnt_menu = "main_menu"

	local list = ui.List(512, 32, {
		ui.Button(ui.Text(i18n "menu.versus", fnt_menu), 0, 0):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () core.rooms:set("battle") end),

		ui.Button(ui.Text("MyROOM", fnt_menu), 0, 64):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () core.rooms:change("myroom") end),

		ui.Button(ui.Text(i18n "menu.settings", fnt_menu), 0, 128):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () core.rooms:push("settings") end),

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
		core.sound:setMusic("music/main.mp3")
		self.scenes = {
			core.image.load("sprites/UI/MainMenu/1.png",nil,nil,{linear = false}),
			core.image.load("sprites/UI/MainMenu/2.png",nil,nil,{linear = false}),
			core.image.load("sprites/UI/MainMenu/3.png",nil,nil,{linear = false}),
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
			core.rooms:set("settings")
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

		core.image.draw(self.scenes[self.scene], 0, settings.gameHeight - 240, 0, nil, 2)

		local ro, go, bo, ao = love.graphics.getColor()
		love.graphics.setColor(0,0,0,self.opacity)
		love.graphics.rectangle("fill", 0, 0, settings.global.width, settings.global.height)
		love.graphics.setColor(ro, go, bo, ao)
	end




return room