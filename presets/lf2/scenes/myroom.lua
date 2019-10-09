local core = l2df
local Scene = core.import 'core.class.entity.scene'
local UI = core.import 'core.class.entity.ui'
local parser = core.import 'parsers.lffs'

local event = core.import 'core.manager.event'

local room = Scene {
	nodes = {
		UI.Image {
			sprites = 'sprites/test/1.png',
			x = 200,
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
	x = 75,
	y = 18,
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


f = function (_, key)
	if key == 'w' then
		room.nodes.list[1].vars.y = room.nodes.list[1].vars.y - 3
	elseif key == 's' then
		room.nodes.list[1].vars.y = room.nodes.list[1].vars.y + 3
	elseif key == 'a' then
		room.nodes.list[1].vars.x = room.nodes.list[1].vars.x - 3
	elseif key == 'd' then
		room.nodes.list[1].vars.x = room.nodes.list[1].vars.x + 3
	elseif key == 'r' then
		room.nodes.list[1].vars.r = room.nodes.list[1].vars.r - 3
	elseif key == 'f' then
		room.nodes.list[1].vars.r = room.nodes.list[1].vars.r + 3
	elseif key == 'y' then
		room.nodes.list[1].vars.scaleY = room.nodes.list[1].vars.scaleY + 0.5
	elseif key == 'h' then
		room.nodes.list[1].vars.scaleY = room.nodes.list[1].vars.scaleY - 0.5
	elseif key == 'u' then
		room.nodes.list[1].vars.scaleX = room.nodes.list[1].vars.scaleX + 0.5
	elseif key == 'j' then
		room.nodes.list[1].vars.scaleX = room.nodes.list[1].vars.scaleX - 0.5
	elseif key == 'f1' then
		n.vars.hidden = not n.vars.hidden
	end
end

f2 = function (_, key)
	if key == 'o' then
		m.vars.y = m.vars.y - 3
	elseif key == 'l' then
		m.vars.y = m.vars.y + 3
	elseif key == 'k' then
		m.vars.x = m.vars.x - 3
	elseif key == ';' then
		m.vars.x = m.vars.x + 3
	elseif key == 'v' then
		m.vars.r = m.vars.r - 3
	elseif key == 'b' then
		m.vars.r = m.vars.r + 3
	elseif key == 'n' then
		m.vars.scaleY = m.vars.scaleY + 0.5
	elseif key == 'm' then
		m.vars.scaleY = m.vars.scaleY - 0.5
	elseif key == 'x' then
		m.vars.scaleX = m.vars.scaleX + 0.5
	elseif key == 'c' then
		m.vars.scaleX = m.vars.scaleX - 0.5
	end
end

event:subscribe('keypressed', f)
event:subscribe('keypressed', f2)

return room