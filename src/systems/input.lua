local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "InputSystem works only with l2df v1.0 and higher")

local System = core.import "core.entities.system"
local input = core.import "input"
local helper = core.import "helper"

local InputSystem = System:extend()

	function InputSystem:init()
		helper.hook(input, "press", function (i, ...) self.manager:emit("press", ...) end)
		helper.hook(input, "release", function (i, ...) self.manager:emit("release", ...) end)
	end

	function InputSystem:keypressed(key)
		input:keypressed(key)
	end

	function InputSystem:keyreleased(key)
		input:keyreleased(key)
	end

return InputSystem