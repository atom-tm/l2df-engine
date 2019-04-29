rooms = {}

	function rooms:initialize()
		rooms.list = helper.requireAllFromFolder(settings.global.roomsFolder)
	end

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