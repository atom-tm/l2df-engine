local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Core.Entities.Component works only with l2df v1.0 and higher")

local Object = core.import "core.object"
local helper = core.import "helper"

local copyTable = helper.copyTable

local Component = Object:extend()

	function Component:init(entity)
		local class = self
		while class and not class:isTypeOf(Object) do
			for k, v in pairs(class) do
				if k:sub(1, 1) ~= "_" and k ~= "super" and k ~= "init" then
					entity[k] = copyTable(v, entity[k])
				end
			end
			class = class.___class
		end
	end

return Component