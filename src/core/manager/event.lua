local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "EntityManager works only with l2df v1.0 and higher")

local Storage = core.import "core.class.storage"

local subscribers = { }
local submap = { }
local events = { }

local Manager = { }

	function Manager:subscribe(id, func, source)
		if type(id) == "string" then
			subscribers[id] = subscribers[id] or Storage:new()
			return subscribers[id]:add({ func, source })
		elseif type(id) == "table" then
			local ids = {}
			for key, val in pairs(id) do
				subscribers[key] = subscribers[id] or Storage:new()
				ids[#ids] = subscribers[key]:add({ id[key] })
			end
			return ids
		end
	end

	function Manager:unsubscribe(id, func, sourse)
		subscribers[id]:remove({ func, source })
	end

	function Manager:unsubscribeById(id, i)
		subscribers[id]:removeById(i)
	end

	function Manager:getSubscribes()
		for key, val in pairs(subscribers) do
			print(key .. " - " .. #val.list)
		end
	end





	function Manager:invocation(id, source, params)
		events[#events] = {id, source, params}
	end

	function Manager:monitoring()

	end

return Manager