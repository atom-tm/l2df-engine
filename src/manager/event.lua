--- Event manager.
-- @classmod l2df.manager.event
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EventManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local SceneManager = core.import 'manager.scene'
local Storage = core.import 'class.storage'
local hook = helper.hook
local unpack = table.unpack or unpack

local subscribers = { }
local handlers = { }
local update_events = {
	{'preupdate','beforepreupdate'},
	{'update','beforeupdate', true},
	{'postupdate','beforepostupdate'},
	{'lastupdate','beforelastupdate'}
}

local Manager = { active = true }

	--- EventManager's enabled state. `true` by default.
	-- It is not actually used yet.
	-- @field boolean Manager.active

	--- Default @{l2df.manager.event.UpdateEvent|update events} bindings.
	-- These events are executed in the same order they are represented here (or at `kwargs.updates` passed to
	-- @{l2df.manager.event.init|EventManager:init()}) on each @{l2df.manager.event.update|EventManager:update()} call.
	-- @field {'preupdate','beforepreupdate',false} 1
	-- @field {'update','beforeupdate',true} 2
	-- @field {'postupdate','beforepostupdate',false} 3
	-- @field {'lastupdate','beforelastupdate',false} 4
	-- @table .DefaultUpdateEvents

	--- Custom update event description.
	-- @field string 1  `(event)` Name of the custom update event.
	-- @field string 2  `(before_event)` Name of the event which
	-- will be triggered before actual `event`.
	-- @field boolean 3  `(lift_support)` Add support for "liftdown"
	-- and "liftup" callbacks during this `event`. `false` by default.
	-- @table .UpdateEvent

	--- Configure @{l2df.manager.event|EventManager}.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt] {l2df.manager.event.UpdateEvent,...} kwargs.updates  Customizes update events.
	-- Overrides @{l2df.manager.event.DefaultUpdateEvents|default bindings}.
	-- @return l2df.manager.event
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		update_events = kwargs.updates or update_events
		return self
	end

	--- Embed references to @{l2df.manager.event|EventManager's} methods in the entity instance that you create.
	-- Embedded methods are:
	-- @{Manager.subscribe|subscribe}, @{Manager:unsubscribe|unsubscribe} and @{Manager:unsubscribeById|unsubscribeById}.
	-- @param l2df.class.entity entity  Entity's instance.
	function Manager:classInit(entity)
		if not entity:isInstanceOf(Entity) then return end
		entity.subscribe = self.subscribe
		entity.unsubscribe = self.unsubscribe
		entity.unsubscribeById = self.unsubscribeById
	end

	--- Allows the object to listen events sent to the Manager.
	-- @param l2df.class.entity|table subscriber  Subscriber object.
	-- @param[opt=false] boolean subscriber.active  @{l2df.manager.event|EventManager} will watch for this property
	-- on each @{l2df.manager.event.invoke|EventManager:invoke()} call. If `false` the fired event will be ignored
	-- @param string event  Name of the event.
	-- @param function handler  Callback function which would be called with an invoked event.
	-- @param l2df.class.entity source  Source object of the calling event.
	-- If event with the same name comes from another source it would be ignored.
	-- @return number  Subscription ID. Can be used with @{l2df.manager.event.unsubscribeById|EventManager:unsubscribeById()}.
	function Manager.subscribe(subscriber, event, handler, source, ...)
		if not (type(event) == 'string' and subscriber and type(handler) == 'function') then return end
		subscribers[event] = subscribers[event] or Storage:new()
		local id = subscribers[event]:add({ subscriber = subscriber, handler = handler, source = source, params = {...} })
		handlers[event] = handlers[event] or { }
		handlers[event][handler] = id
		return id
	end

	--- Disables event tracking by objects using handler.
	-- @param string event  Name of the event.
	-- @param function handler  Handler function which was @{l2df.manager.event.subscribe|subcribed}.
	-- @return boolean  `true` if unsubscribed, `false` otherwise.
	function Manager:unsubscribe(event, handler)
		local id = handlers[event][handler]
		return self:unsubscribeById(event, id)
	end

	--- Disables event tracking by objects using ID.
	-- @param string event  Name of the event.
	-- @param number id  ID returned by @{l2df.manager.event.subscribe|EventManager:subscribe()}.
	-- @return boolean  `true` if unsubscribed, `false` otherwise.
	function Manager:unsubscribeById(event, id)
		return (event and id and subscribers[event]:removeById(id)) or false
	end

	--- Invoke an event for all active subscribers.
	-- @param string event  Name of the event.
	-- @param l2df.class.entity source  Source object of the calling event.
	-- It is used by @{l2df.manager.event.subscribe|EventManager:subscribe()} to filter out events depending on its source.
	function Manager:invoke(event, source, ...)
		if not subscribers[event] then return end
		for key, val in subscribers[event]:enum(true) do
			if val.subscriber.active and (not val.source or val.source == source) then
				local len = #val.params
				for i = 1, select('#', ...) do
					val.params[len + i] = select(i, ...)
				end
				val.handler(unpack(val.params))
				for i = #val.params, len + 1, -1 do
					val.params[i] = nil
				end
			end
		end
	end

	--- Monitors whether an object calls certain functions.
	-- @param l2df.class.entity|table source  Source object of the calling event.
	-- It is used by @{l2df.manager.event.subscribe|EventManager:subscribe()} to filter out events depending on its source.
	-- @param table|string events  Name(s) of the field(s) containing function to hook.
	-- @param[opt] table|string alias  If setted makes an alias which would be passed to the.
	-- @{l2df.manager.event.invoke|EventManager:invoke()} method instead of the original function name.
	-- @param[opt=false] boolean save_result  Whether to save the result of the function execution.
	function Manager:monitoring(source, events, alias, save_result)
		-- TODO: save_result is not working, fix it
		save_result = save_result and false --not not save_result
		if type(events) == 'string' then
			local event = alias or events
			hook(source, events, function (...) Manager:invoke(event, source, ...) end, save_result)
		elseif type(events) == 'table' then
			for key in pairs(events) do
				local event = alias and alias[key] or key
				hook(source, key, function (...) Manager:invoke(event, source, ...) end, save_result)
			end
		end
	end

	local function initUpdate(event)
		local beginner = { SceneManager.root }
		local current = { beginner, 0, #beginner }
		return event[2] or 'before' .. event[1], event[1], not not event[3], { current }, beginner, current, 0, 1
	end

	--- Update event handler.
	-- Executes @{l2df.manager.event.UpdateEvent|UpdateEvents} on each @{l2df.class.entity|entity} and its.
	-- @{l2df.class.component|components} in the order they were passed to @{l2df.manager.event.init|EventManager:init()}.
	-- @param ... ...  Passes all arguments to each update event and `liftdown` / `liftup` callbacks.
	function Manager:update(...)
		local empty_table, c, _ = { }
		for k = 1, #update_events do
			local before, event, dolift, tasks, beginner, current, i, depth = initUpdate(update_events[k])
			self:invoke(before, self, ...)
			while i < current[3] or depth > 1 do
				i = i + 1
				local object = current[1][i]
				local nodes = nil

				-- update object components for current item
				if object and object.active then
					nodes = object:getNodes()
					_ = object[event] and object[event](object, ...)
					c = object:getComponents() or empty_table
					for j = 1, #c do
						_ = c[j][event] and c[j][event](...)
					end
				end

				-- lift down
				if nodes and #nodes > 0 then
					if dolift then
						c = object and object:getComponents() or empty_table
						for j = 1, #c do
							_ = c[j].liftdown and c[j].liftdown(...)
						end
					end
					current[2] = i
					current = { nodes, 0, #nodes }
					depth = depth + 1
					tasks[depth] = current
					i = 0

				-- lift up
				elseif i >= current[3] and depth > 1 then
					depth = depth - 1
					current = tasks[depth]
					i = current[2]
					object = current[1][i]
					if dolift then
						c = object and object:getComponents() or empty_table
						for j = 1, #c do
							_ = c[j].liftup and c[j].liftup(...)
						end
					end

				-- bottom layer
				-- else
				end
			end
			self:invoke(event, self, ...)
		end
	end

return setmetatable(Manager, { __call = Manager.init })