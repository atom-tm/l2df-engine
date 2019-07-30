local core = l2df
assert(type(core) == "table" and core.version >= 1.0, "Rooms works only with love2d-fighting v1.0 and higher")

local hook = helper.hook

local rooms = { list = { } }

	function rooms:init()
		self.list = helper.requireAllFromFolder(core.settings.global.rooms_path)

		local events = love.handlers
		events.update = true

		for key in pairs(events) do
			hook(love, key, function (...) self:trigger(key, ...) end)
		end

		hook(core, "localechanged", function () self:forceTrigger("localechanged") end, core)
		hook(love, "draw", function (...)
			love.graphics.setCanvas(core.canvas)
			love.graphics.clear()
			self:trigger("draw", ...)
			love.graphics.setCanvas()
		end)

		self:set(core.settings.global.startRoom)
	end

	function rooms:trigger(event, ...)
		return self:__trigger(event, false, ...)
	end

	function rooms:forceTrigger(event, ...)
		return self:__trigger(event, true, ...)
	end

	function rooms:set(room, input)
		input = input or { }
		local _ = self.current and self.current.exit and self.current:exit()
		self.current = self.list[tostring(room)]
		local _ = self.current.load and self.current:load(input)
		self:forceTrigger("roomloaded")
	end

	function rooms:reload(input)
		local _ = self.current.load and self.current:load(input)
		self:forceTrigger("roomloaded")
	end

	function rooms:__trigger(event, force, ...)
		if self.current and self.current.nodes and next(self.current.nodes) then
			local containers = { {self.current.nodes, 1, #self.current.nodes} }
			local current = containers[1]
			local node = nil
			local head = 1
			local i = 1

			while head > 1 or i <= current[3] do
				node = current[1][i]
				i = i + 1

				if node and (force or not node.hidden) and type(node[event]) == "function" then
					node[event](node, ...)
				end

				if node and node.childs and next(node.childs) then
					current[2] = i
					containers[head + 1] = { node.childs, 1, #node.childs }
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
		return self.current and self.current[event] and self.current[event](self.current, ...)
	end

return rooms