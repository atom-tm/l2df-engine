local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EntityManager works only with l2df v1.0 and higher')

local Storage = core.import 'core.class.storage'

local hook = helper.hook
local subscribers = { }

local Manager = { }

	function Manager:subscribe(event, func, source, ...)
		if type(event) == 'string' then
			subscribers[event] = subscribers[event] or Storage:new()
			return subscribers[event]:add({ func, source, ... })
		elseif type(event) == 'table' then
			local ids = {}
			for key, val in pairs(event) do
				subscribers[key] = subscribers[event] or Storage:new()
				ids[key] = subscribers[key]:add({ event[key] })
			end
			return ids
		end
	end

	function Manager:unsubscribeById(event, id)
		return event and id and subscribers[event]:removeById(id)
	end

	function Manager:invoke(event, source, ...)
		if subscribers[event] then
			for key, val in subscribers[event]:enum(true) do
				if val and (not val[2] or val[2] == source) then
					val[1](val[3], ...)
				end
			end
		end
	end

	function Manager:monitoring(object, events)
		if type(events) == 'string' then
			hook(object, events, function ( ... ) Manager:invoke(events, object, ...) end)
		elseif type(events) == 'table' then
			for key in pairs(events) do
				hook(object, key, function (...) Manager:invoke(key, object, ...) end)
			end
		end
	end

return Manager