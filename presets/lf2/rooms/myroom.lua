local core = l2df -- core (important)
local ui = core.ui -- UI module (important)
local i18n = core.i18n

local settings = core.settings.global -- settings module

-- ^ modules \\ librarys --

local room = {} -- room object

	love.graphics.setBackgroundColor(1,1,1,1)

	local template_text = ui.Text("Some text", nil, 10, 10, { 1, 1, 1, 1})
	local butt = ui.Button(ui.Text(i18n "settings.back", "settings_menu"), 256, 256):useMouse(true)
					:on("update", function (self) self.text.color[1] = self.hover and 1 or 0 end)
					:on("click", function () core.rooms:pop() end)
	room.nodes = {
		template_text,
		butt,
	}



return room