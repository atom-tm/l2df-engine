local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "PhysixSystem works only with l2df v1.0 and higher")

local Object = core.import "core.object"

local Room = Object:extend()

return Room