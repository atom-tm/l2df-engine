local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Core.Entities.System works only with l2df v1.0 and higher")

local Object = core.import "core.object"

local System = Object:extend({ manager = { }, groups = { } })

return System