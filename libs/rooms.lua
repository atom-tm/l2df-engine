local rooms = { list = { } }

	function rooms:init()
		rooms.list = helper.requireAllFromFolder(settings.global.roomsFolder)
		for key in pairs(love.handlers) do
			local old_func = love[key] or function() end
			love[key] = function (...)
				old_func(...);

				if rooms.current[key] then
					rooms.current[key](rooms.current, ...)
				end
			end
		end
		rooms:set(settings.global.startRoom)
	end

	function rooms:set(room, input)
		input = input or { }
		rooms.current = rooms.list[tostring(room)]
		rooms.current:load(input)
	end

	function rooms:reload(input)
		rooms.current:load(input)
	end
	
return rooms