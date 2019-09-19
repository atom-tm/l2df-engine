local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Class = core.import "core.class"

local Component = Class:extend()

	function Component:init(i)
		self.x = i
	end

	function Component:added(entity)
		print("Component sucsefully added")
		entity.x = self.x
		-- pass
	end

	function Component:removed(entity)
		print("Component sucsefully removed")
		-- pass
	end

return Component