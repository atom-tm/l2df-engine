local interception = helper.interception

local rooms = { list = { } }

	function rooms:init()
		self.list = helper.requireAllFromFolder(settings.global.roomsFolder)

		local events = love.handlers
		events.update = true

		for key in pairs(events) do
			interception(key, function (...)
				return self.current[key] and self.current[key](self.current, ...)
			end)
		end

		interception("draw", function (...)
			love.graphics.setCanvas(mainCanvas)
			love.graphics.clear()
			local _ = self.current.draw and self.current:draw(...)
			love.graphics.setCanvas()
		end)

		self:set(settings.global.startRoom)
	end


	function rooms:set(room, input)
		input = input or { }
		local _ = self.current and self.current.exit and self.current:exit()
		self.current = self.list[tostring(room)]
		local _ = self.current.load and self.current:load(input)
	end


	function rooms:reload(input)
		local _ = self.current.load and self.current:load(input)
	end
	
	
return rooms