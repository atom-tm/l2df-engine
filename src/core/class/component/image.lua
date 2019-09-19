local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"

local Image = Component:extend({ unique = true })

	function Image:init()

	end

	function Image:added()
		print("Image component added")
	end

return Image