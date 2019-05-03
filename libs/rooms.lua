local interception = helper.interception

local rooms = { list = { } }

	function rooms:init()
		self.list = helper.requireAllFromFolder(settings.global.roomsFolder)

		local next = next
		local events = love.handlers
		events.update = true

		for key in pairs(events) do
			interception(key, function (...) self:handleEvent(key, ...) end)
		end

		interception("draw", function (...)
			love.graphics.setCanvas(mainCanvas)
			love.graphics.clear()
			self:handleEvent("draw", ...)
			love.graphics.setCanvas()
		end)

		self:set(settings.global.startRoom)
	end

	function rooms:handleEvent(key, ...)
		if self.current.nodes and next(self.current.nodes) then
			local containers = { {self.current.nodes, 1, #self.current.nodes} }
			local current = containers[1]
			local node = nil
			local head = 1
			local i = 1

			while head > 1 or i <= current[3] do
				node = current[1][i]
				i = i + 1
				if not node.hidden and type(node[key]) == "function" then node[key](node, ...) end
				if node.childs and next(node.childs) then
					current[2] = i
					containers[head + 1] = { node.childs, 1, node.size }
					head = head + 1
					current = containers[head]
					i = 1
				elseif i > current[3] and head > 1 then
					head = head - 1
					current = containers[head]
					i = current[2]
				end
			end
		end
		return self.current[key] and self.current[key](self.current, ...)
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