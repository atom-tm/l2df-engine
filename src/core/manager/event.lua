local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "EntityManager works only with l2df v1.0 and higher")

local Storage = core.import "core.class.storage"

local hook = helper.hook
local subscribers = { }

local Manager = { }

	function Manager:subscribe(id, func, source, ...)
		if type(id) == "string" then
			subscribers[id] = subscribers[id] or Storage:new()
			return subscribers[id]:add({ func, source, ... })
		elseif type(id) == "table" then
			local ids = {}
			for key, val in pairs(id) do
				subscribers[key] = subscribers[id] or Storage:new()
				ids[key] = subscribers[key]:add({ id[key] })
			end
			return ids
		end
	end

	function Manager:unsubscribeById(id, i)
		return id and i and subscribers[id]:removeById(i)
	end

	function Manager:getSubscribes()
		for key, val in pairs(subscribers) do
			print(key .. " - " .. #val.list)
		end
	end

	function Manager:invoke(id, source, ...)
		if subscribers[id] then
			for key, val in subscribers[id]:enum(true) do
				if val and (not val[2] or val[2] == source) then
					val[1](val[3], ...)
				end
			end
		end
	end

	function Manager:monitoring(object, events)
		if type(events) == "string" then
			hook(object, events, function ( ... ) Manager:invoke(events, object, ...) end)
		elseif type(events) == "table" then
			for key in pairs(events) do
				hook(object, key, function (...) Manager:invoke(key, object, ...) end)
			end
		end
	end

return Manager