local rooms = { list = { } }

	function rooms:init()
	local dummy = function () end
		rooms.list = helper.requireAllFromFolder(settings.global.roomsFolder)
		
		for key in pairs(love.handlers) do
			local old_func = love[key] or dummy
			love[key] = function (...)
				old_func(...)
				local _ = rooms.current[key] and rooms.current[key](rooms.current, ...)
			end
		end

		local oldUpdate = love.update or dummy
		love.update = function (...)
			oldUpdate(...)
			local _ = rooms.current.update and rooms.current:update(...)
		end

		local oldDraw = love.draw or dummy
		love.draw = function (...)
			oldDraw(...)
			local _ = rooms.current.draw and rooms.current:draw(...)
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