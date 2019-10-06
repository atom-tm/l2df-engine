local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EventManager works only with l2df v1.0 and higher')

local EntityManager = core.import 'core.manager.entity'
local Storage = core.import 'core.class.storage'
local hook = helper.hook

local subscribers = { }
local handlers = { }

local Manager = { active = true }

	--- Embed references to Manager methods in the entity instance that you create
	--  @tparam Entity entity
	function Manager:classInit(entity)
		if not entity:isInstanceOf(Entity) then return end
		entity.subscribe = self.subscribe
		entity.unsubscribe = self.unsubscribe
		entity.unsubscribeById = self.unsubscribeById
	end

	--- Allows the object to listen events sent to the Manager
	--  @tparam Entity subscriber
	--  @tparam string event
	--  @tparam function handler
	--  @tparam Entity source
	function Manager.subscribe(subscriber, event, handler, source, ...)
		if not (type(event) == 'string' and subscriber and handler) then return end
		subscribers[event] = subscribers[event] or Storage:new()
		local id = subscribers[event]:add({ subscriber = subscriber, handler = handler, source = source, params = ... })
		handlers[event] = handlers[event] or { }
		handlers[event][handler] = id
		return id
	end

	--- Disables event tracking by objects using handler
	--  @tparam string event
	--  @tparam function handler
	function Manager:unsubscribe(event, handler)
		local id = handlers[event][handler]
		return self:unsubscribeById(event, id)
	end

	--- Disables event tracking by objects using Id
	--  @tparam string event
	--  @tparam number id
	function Manager:unsubscribeById(event, id)
		return (event and id and subscribers[event]:removeById(id)) or false
	end

	--- Invoke an event for all active subscribers
	--  @tparam string string
	--  @tparam Entity source
	function Manager:invoke(event, source, ...)
		if not subscribers[event] then return end
		for key, val in subscribers[event]:enum(true) do
			if val.subscriber.active and (not val.source or val.source == source) then
				val.handler(val.params, ...)
			end
		end
	end

	--- Monitors whether an object calls certain functions
	--  @tparam Entity sourse
	--  @tparam table|string events
	--  @tparam boolean save_result whether to save the result of the function execution
	function Manager:monitoring(source, events, save_result)
		save_result = save_result and false
		if type(events) == 'string' then
			hook(source, events, function (...) Manager:invoke(events, source, ...) end, save_result)
		elseif type(events) == 'table' then
			for key in pairs(events) do
				hook(source, key, function (...) Manager:invoke(key, source, ...) end, save_result)
			end
		end
	end

	---
	function Manager:update(...)
		local beginer = { EntityManager.root }
		local tasks = { { beginer, 0, #beginer } }
		local depth = 1
		local i = 0
		local current = tasks[depth]
		while i < current[3] or depth > 1 do
			i = i + 1
			local object = current[1][i]
			local nodes = nil
			if object and object.active then
				nodes = object:getNodes()
				c = object and object:getComponents() or { }
				for j = 1, #c do
					local _ = c[j].preUpdate and c[j]:preUpdate(...)
				end
				c = object and object:getComponents() or { }
				for j = 1, #c do
					local _ = c[j].update and c[j]:update(...)
				end
			end
			if nodes and #nodes > 0 then
				c = object and object:getComponents() or { }
				for j = 1, #c do
					local _ = c[j].push and c[j]:push(...)
				end
				current[2] = i
				current = { nodes, 0, #nodes }
				depth = depth + 1
				tasks[depth] = current
				i = 0
			elseif i >= current[3] and depth > 1 then
				c = object and object:getComponents() or { }
				for j = 1, #c do
					local _ = c[j].postUpdate and c[j]:postUpdate(...)
				end
				depth = depth - 1
				current = tasks[depth]
				i = current[2]
				object = current[1][i]
				c = object and object:getComponents() or { }
				for j = 1, #c do
					local _ = c[j].pop and c[j]:pop(...)
				end
			else
				c = object and object:getComponents() or { }
				for j = 1, #c do
					local _ = c[j].postUpdate and c[j]:postUpdate(...)
				end
			end
		end
	end

return Manager