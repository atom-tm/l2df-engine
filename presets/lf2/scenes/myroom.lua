local core = l2df
local Scene = core.import 'core.class.entity.scene'
local UI = core.import 'core.class.entity.ui'
local parser = core.import 'parsers.lffs'

local sometext = UI.Text(parser:parse[[
	text: "o_O PRESS 'P' TO PAY O_o"  font: 35
	x: 50 y: 205
]])

local room = Scene {
	nodes = {
		UI.Text {
			text = 'GG WP',
			font = 25,
			x = 220,
			y = 110
		},
		parser:parse [[
			<text>
				text: "PRESS F TO PAY RESPECT"  font: 18
				x: 225 y: 135
			</text>
		]],
		sometext
	}
}

return room