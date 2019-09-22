local core = l2df
local ui = core.ui
local settings = core.settings
local i18n = core.i18n
local Media = core.import "media"
local Room = core.import "rooms.room"

local repo = l2df.import "repository.char"
local Char = l2df.import "entities.char"

local loveGetColor = love.graphics.getColor
local loveSetColor = love.graphics.setColor
local loveRectangle = love.graphics.rectangle
local loveSetColor = love.graphics.setColor

local room = Room:extend()

	local fnt_menu = "main_menu"

	room.bgm = Media.Music("music/main.mp3")
	room.manager:add(room.bgm)

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

		room.bgm:play()

		self.opacity = 1
		self.scenes = {
			Media.Image("sprites/UI/MainMenu/1.png", nil, nil, {linear = false}),
			Media.Image("sprites/UI/MainMenu/2.png", nil, nil, {linear = false}),
			Media.Image("sprites/UI/MainMenu/3.png", nil, nil, {linear = false}),
		}
		self.scene = math.random(1, #self.scenes)

		if not self.char then
			self.char = Char(repo.get(1))
			self.manager:add(self.char)
		end
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
		if key == "f7" then
			room.bgm:change("music/main.mp3")
		end
		if key == "f8" then
			room.bgm:change("music/battle.mp3")
		end
		if key == "f9" then
			room.bgm:volume(room.bgm.info.volume - 10)
		end
		if key == "f10" then
			room.bgm:volume(room.bgm.info.volume + 10)
		end
	end

	function room:draw()
		self.scenes[self.scene]:draw(0, settings.gameHeight - 240, 0, nil, 2)
	end




return room