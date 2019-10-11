local core = l2df
local Scene = core.import 'core.class.entity.scene'
local UI = core.import 'core.class.entity.ui'
local parser = core.import 'parsers.lffs'

local Physix = core.import 'core.class.component.physix'
local event = core.import 'core.manager.event'

local room = Scene {
	nodes = {
		UI.Image {
			sprites = 'sprites/test/1.png',
			x = 20,
			y = 150,
		},
		parser:parse [[
			<text>
				text: "PRESS F TO PAY RESPECT"  font: 18
				x: 0 y: 0
			</text>
		]]
	}
}

local m = UI.Image {
	sprites = 'sprites/test/2.png',
	x = 0,
	y = 0,
}
m.vars.centerX = 8
m.vars.centerY = 5


local n = UI.Image {
	sprites = 'sprites/test/3.png',
	x = 27,
	y = 3,
}
n.vars.centerX = 10
n.vars.centerY = 10
n.vars.z = 2
n.vars.hidden = true

room.nodes.list[1]:attach(m)
room.nodes.list[1]:attach(n)

room.nodes.list[1].vars.centerX = 30
room.nodes.list[1].vars.centerY = 28

room:addComponent(Physix.Controller {
	wind = 0,
	maxSpeed = 10
})



f = function (_, key)
	if key == 'w' then
		room.nodes.list[1].vars.dvy = -1
	elseif key == 's' then
		room.nodes.list[1].vars.dvy = 1
	elseif key == 'a' then
		room.nodes.list[1].vars.dvx = -5
	elseif key == 'd' then
		room.nodes.list[1].vars.dvx = 5
	elseif key == 'f3' then
		room.nodes.list[1]:getComponent(Physix).through = not room.nodes.list[1]:getComponent(Physix).through
	elseif key == 'f2' then
		room.nodes.list[1]:getComponent(Physix).gravity = not room.nodes.list[1]:getComponent(Physix).gravity
	elseif key == 'f1' then
		n.vars.hidden = not n.vars.hidden
	end
end

event:subscribe('keypressed', f)

return room