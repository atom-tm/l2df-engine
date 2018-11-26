
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

	letter = {}
	local string_letters = "qwertyuiopasdfghjklzxcvbnm1234567890"
	for i = 1, string_letters:len() do
		local code = string.byte(string_letters, i);
		letter[string.char(code)..0] = LoadImage("sprites/UI/Letters/"..string.char(code).."0.png")
		letter[string.char(code)..0]:setFilter("linear","linear")
		letter[string.char(code)..1] = LoadImage("sprites/UI/Letters/"..string.char(code).."1.png")
		letter[string.char(code)..1]:setFilter("linear","linear")
	end

	letter["lbr"..0] = LoadImage("sprites/UI/Letters/".."lbr0.png")
	letter["lbr"..0]:setFilter("linear","linear")
	letter["lbr"..1] = LoadImage("sprites/UI/Letters/".."lbr1.png")
	letter["lbr"..1]:setFilter("linear","linear")

	letter["rbr"..0] = LoadImage("sprites/UI/Letters/".."rbr0.png")
	letter["rbr"..0]:setFilter("linear","linear")
	letter["rbr"..1] = LoadImage("sprites/UI/Letters/".."rbr1.png")
	letter["rbr"..1]:setFilter("linear","linear")

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


function print(input_string, x, y, selected, size, tracking)
	if tracking == nil then tracking = -15 end
	if size == nil then size = 1 end
	input_string = string.lower(input_string)
	for i = 1, input_string:len() do
		local code = string.byte(input_string, i);
		if code == 32 then
			x = x + 30 * size + tracking
		elseif code == 40 then
			if selected == true or selected == 1 then
				love.graphics.draw(letter["lbr"..1],x,y, 0, size, size)
				x = x + letter["lbr"..1]:getWidth() * size + tracking
			else
				love.graphics.draw(letter["lbr"..0],x,y, 0, size, size)
				x = x + letter["lbr"..0]:getWidth() * size + tracking
			end
		elseif code == 41 then
			if selected == true or selected == 1 then
				love.graphics.draw(letter["rbr"..1],x,y, 0, size, size)
				x = x + letter["rbr"..1]:getWidth() * size + tracking
			else
				love.graphics.draw(letter["rbr"..0],x,y, 0, size, size)
				x = x + letter["rbr"..0]:getWidth() * size + tracking
			end
		else
			if selected == true or selected == 1 then
				love.graphics.draw(letter[string.char(code)..1],x,y, 0, size, size)
				x = x + letter[string.char(code)..1]:getWidth() * size + tracking
			else
				love.graphics.draw(letter[string.char(code)..0],x,y, 0, size, size)
				x = x + letter[string.char(code)..0]:getWidth() * size + tracking
			end
		end
	end
end