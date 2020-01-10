local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local State = core.import "class.state"

local State = State:new()

	function State:persistentUpdate(entity, vars)
		entity.x = entity.x + vars.speed
		if entity.x > 300 or entity.x < 0 then vars.speed = -vars.speed end
	end

	function State:update(entity, vars)
		entity.y = entity.y + vars.speed
	end

return State