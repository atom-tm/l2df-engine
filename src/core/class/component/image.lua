local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local MResourse = core.import "core.manager.resourse"
assert(type(MResourse) == "table", "This component requires a Resource Manager among the connected")

local Component = core.import "core.class.component"

local Image = Component:extend()

	function Image:init()
		-- body
	end

return Image