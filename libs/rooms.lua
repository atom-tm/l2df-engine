rooms = {}
	rooms.list = {
		main_menu = require("rooms.main_menu"),
		settings = require("rooms.settings"),
		controls = require("rooms.controls"),
		character_select = require("rooms.character_select"),
		loading = require("rooms.loading"),
		battle = require("rooms.battle"),
	}
	function rooms:Set(id, table_values)
		if self.name ~= nil then
			self.last = self.name
		else
		    self.last = "none"
		end
		self.name = id
		self.current = rooms.list[id]
		self.current:Load(table_values)
	end
	function rooms:Reload(table_values)
		self.current:Load(table_values)
	end
return rooms

--[[function roomsLoad()
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
end]]