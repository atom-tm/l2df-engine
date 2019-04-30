rooms = {}

	function rooms:initialize()
		rooms.list = helper.requireAllFromFolder(settings.global.roomsFolder)
		for key in pairs(love.handlers) do
			love.window.showMessageBox( "..", key, "info", true)
		end
		rooms:set(settings.global.startRoom)
	end

	function rooms:set(room, input)
		input = input or {}
		self.current = rooms.list[tostring(room)]
		self.current:load(input)
	end

	function rooms:reload(input)
		self.current:load(input)
	end
	
return rooms