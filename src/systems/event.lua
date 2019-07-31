local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "EventSystem works only with l2df v1.0 and higher")

local System = core.import "core.entities.system"

local rawget = _G.rawget

local EventSystem = System:extend()

	function EventSystem:new(...)
		self.child = self.super.new(self, ...)
		return self.child
	end

	function EventSystem:init(options)
		options = options or { }

		self.forced = { }
		options.forced = options.forced or { }
		for i = 1, #options.forced do
			self.forced[options.forced[i]] = true
		end

		self.except = { }
		options.except = options.except or { }
		for i = 1, #options.except do
			self.except[options.except[i]] = true
		end
	end

local function dummyFunction() end

local EventProxy = { ___events = { } }

	function EventProxy:generateEvent(event)
		if self.child.except[event] then
			return dummyFunction
		elseif self.child.forced[event] then
			return function (self, ...)
				local containers = { {self.manager.entities, 1, #self.manager.entities} }
				local current = containers[1]
				local node = nil
				local head = 1
				local i = 1

				while head > 1 or i <= current[3] do
					node = current[1][i]
					i = i + 1

					if node and type(node[event]) == "function" then
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
		else
			return function (self, ...)
				local containers = { {self.manager.entities, 1, #self.manager.entities} }
				local current = containers[1]
				local node = nil
				local head = 1
				local i = 1

				while head > 1 or i <= current[3] do
					node = current[1][i]
					i = i + 1

					if node and not node.hidden and type(node[event]) == "function" then
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
		end
	end

return setmetatable(EventProxy, {
		__call = function (cls, ...) return cls:new(...) end,
		__index = function (t, key)
			if EventSystem[key] ~= nil then return EventSystem[key] end
			t.___events[key] = t.___events[key] or t:generateEvent(key)
			return t.___events[key]
		end
	})