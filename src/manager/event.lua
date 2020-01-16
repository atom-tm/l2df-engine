--- Event manager
-- @classmod l2df.manager.event
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EventManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local SceneManager = core.import 'manager.scene'
local Storage = core.import 'class.storage'
local hook = helper.hook

local subscribers = { }
local handlers = { }

local Manager = { active = true }

	--- Embed references to Manager methods in the entity instance that you create
	--  @param Entity entity
	function Manager:classInit(entity)
		if not entity:isInstanceOf(Entity) then return end
		entity.subscribe = self.subscribe
		entity.unsubscribe = self.unsubscribe
		entity.unsubscribeById = self.unsubscribeById
	end

	--- Allows the object to listen events sent to the Manager
	--  @param Entity subscriber
	--  @param string event
	--  @param function handler
	--  @param Entity source
	function Manager.subscribe(subscriber, event, handler, source, ...)
		if not (type(event) == 'string' and subscriber and type(handler) == 'function') then return end
		subscribers[event] = subscribers[event] or Storage:new()
		local id = subscribers[event]:add({ subscriber = subscriber, handler = handler, source = source, params = ... })
		handlers[event] = handlers[event] or { }
		handlers[event][handler] = id
		return id
	end

	--- Disables event tracking by objects using handler
	--  @param string event
	--  @param function handler
	function Manager:unsubscribe(event, handler)
		local id = handlers[event][handler]
		return self:unsubscribeById(event, id)
	end

	--- Disables event tracking by objects using Id
	--  @param string event
	--  @param number id
	function Manager:unsubscribeById(event, id)
		return (event and id and subscribers[event]:removeById(id)) or false
	end

	--- Invoke an event for all active subscribers
	--  @param string event
	--  @param Entity source
	function Manager:invoke(event, source, ...)
		if not subscribers[event] then return end
		for key, val in subscribers[event]:enum(true) do
			if val.subscriber.active and (not val.source or val.source == source) then
				val.handler(val.params, ...)
			end
		end
	end

	--- Monitors whether an object calls certain functions
	--  @param Entity source
	--  @param table|string events
	--  @param boolean save_result  Whether to save the result of the function execution
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
		local beginer = { SceneManager.root }
		local tasks = { { beginer, 0, #beginer } }
		local depth = 1
		local i = 0
		local current = tasks[depth]
		while i < current[3] or depth > 1 do
			i = i + 1
			local object = current[1][i]
			local nodes = nil

			-- update components for current item
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

			-- lift down
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

			-- lift up				
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
					local _1 = c[j].pop and c[j]:pop(...)
					local _2 = c[j].postUpdate and c[j]:postUpdate(...)
				end

			-- ???
			else
				c = object and object:getComponents() or { }
				for j = 1, #c do
					local _ = c[j].postUpdate and c[j]:postUpdate(...)
				end
			end
		end
	end

return Manager