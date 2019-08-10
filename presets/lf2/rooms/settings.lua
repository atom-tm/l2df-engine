local l2df = l2df
local ui = l2df.ui
local i18n = l2df.i18n
local settings = l2df.settings

local room = { }

	local settings_font = "settings_menu"

	local list = ui.List(512, 32, {
		ui.Button(ui.Text(i18n "settings.language", settings_font), 0, 0):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () i18n:setLocale() end),

		ui.Button(ui.Text(i18n "settings.music", settings_font), 0, 46):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end),

		ui.Button(ui.Text(i18n "settings.effects", settings_font), 0, 82):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end),

		ui.Button(ui.Text(i18n "settings.save", settings_font), 0, 192):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () settings:save() end),

		ui.Button(ui.Text(i18n "settings.back", settings_font), 0, 256):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () l2df.rooms:pop() end),

		ui.Button(ui.Text("MyROOM", settings_font), 0, 320):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () l2df.rooms:push("myroom") end),
	})

	local music_volume_list = ui.List(512 + 200, 32 + 46, {
		ui.Button(ui.Text( "I", settings_font), 0, 0):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () end),

		ui.Button(ui.Text( "I", settings_font), 10, 0):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () end),

		ui.Button(ui.Text( "I", settings_font), 20, 0):useMouse(true)
			:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
			:on("click", function () end),
	}, true)

	room.nodes = {
		ui.Image("sprites/UI/background.png", 0, 0, nil, nil, "linear"),
		ui.Image("sprites/UI/logotype.png", 25, 25),
		list,
		music_volume_list,
	}

	function room:load()

	end

	function room:update()

	end

	function room:draw()

	end

return room