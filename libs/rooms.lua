rooms = {}

	function rooms:initialize()
		rooms.list = helper.requireAllFromFolder(settings.global.roomsFolder)
		for key in pairs(love.handlers) do
			local old_func = love[key] or function() end
			love[key] = function (...)
				old_func(...)
				if rooms.current[key] then
					rooms.current[key](...)
				end
			end
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