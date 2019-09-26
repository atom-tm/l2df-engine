local core = l2df

local Scene = core.import 'core.class.entity.scene'

local room = Scene:new()

	img = UI.Anim:new(sprites, x, y, "
		<frame> 40 jump_up
		pic: 41  next: 0  wait: 1  centerx: 39 centery: 98
		body: { x: 27  y: 27  w: 33  h: 69  z: -5  l: 10 }

		</frame>

		<frame> 45 jump_forward
		pic: 46  next: 0  wait: 1  centerx: 42 centery: 98
		body: { x: 27  y: 33  w: 37  h: 65  z: -5  l: 10 }
		state: [ 4 { dvx: 18  dvy: 14  dvz: 1  attack: 365 } ]
		</frame>
	 ")

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