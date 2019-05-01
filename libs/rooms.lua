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
			love.graphics.setCanvas(mainCanvas)
			love.graphics.clear()
			local _ = rooms.current.draw and rooms.current:draw(...)
			love.graphics.setCanvas()
		end

		rooms:set(settings.global.startRoom)
	end


	function rooms:set(room, input)
		input = input or { }
		if rooms.current and rooms.current.exit then rooms.current:exit() end
		rooms.current = rooms.list[tostring(room)]
		if rooms.current.load then rooms.current:load(input) end
	end


	function rooms:reload(input)
		if rooms.current.load then rooms.current:load(input) end
	end
	
	
return rooms