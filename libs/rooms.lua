room = {}
room.id = 0

room.load = nil
room.update = nil
room.draw = nil
room.keypressed = nil

rooms_list = {}

function roomsLoad()
	rooms_list[1] = require("rooms.main_menu")
	rooms_list[2] = require("rooms.character_select")
	rooms_list[3] = require("rooms.settings")
	rooms_list[4] = require("rooms.controls")
	setRoom(1)
end

function setRoom(id)
	room.id = id
	if rooms_list[id].load ~= nil then room.load = rooms_list[id].load
	else room.load = function() end end
	if rooms_list[id].update ~= nil then room.update = rooms_list[id].update
	else room.update = function() end end
	if rooms_list[id].draw ~= nil then room.draw = rooms_list[id].draw
	else room.draw = function() end end
	if rooms_list[id].keypressed ~= nil then room.keypressed = rooms_list[id].keypressed
	else room.keypressed = function() end end
	room.load()
end

function print(input_string, x, y, align, font, stroke, width, r, g, b, a)
	if align == nil then align = "left" end
	if font == nil then font = fonts.default end
	if stroke ~= true then stroke = false end
	if width == nil then width = 300 end
	if r == nil then r = 1 end
	if g == nil then g = 1 end
	if b == nil then b = 1 end
	if a == nil then a = 1 end
	local ro,go,bo,ao = love.graphics.getColor()
	love.graphics.setFont(font)
	love.graphics.setColor(r, g, b, a)
	love.graphics.printf(input_string,x,y,width,align)
	love.graphics.setFont(fonts.default)
	love.graphics.setColor(ro, go, bo, ao)
end