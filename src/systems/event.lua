local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "EventSystem works only with l2df v1.0 and higher")

local System = core.import "core.entities.system"

local EventSystem = System:extend()

	function EventSystem:init(options)
		options = options or { }
		self.forced = { }
		if type(options.forced) == "table" then
			for i = 1, #options.forced do
				self.forced[options.forced[i]] = true
			end
		end
	end

return setmetatable({ ___cache = { } }, {
		__index = function (t, key)
			if EventSystem[key] ~= nil then return EventSystem[key] end
			t.___cache[key] = t.___cache[key] or function (self, ...)
				local containers = { {self.manager.entities, 1, #self.manager.entities} }
				local current = containers[1]
				local node = nil
				local head = 1
				local i = 1

				while head > 1 or i <= current[3] do
					node = current[1][i]
					i = i + 1

					if node and (self.forced[key] or not node.hidden) and type(node[key]) == "function" then
						node[key](node, ...)
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
			return t.___cache[key]
		end
	})