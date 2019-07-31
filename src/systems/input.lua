local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "InputSystem works only with l2df v1.0 and higher")

local System = core.import "core.entities.system"
local input = core.import "input"
local helper = core.import "helper"

local InputSystem = System:extend()

	function InputSystem:init()
		helper.hook(input, "press", function (a, b, ...) self.manager:emit("press", ...) end, input)
		helper.hook(input, "release", function (a, b, ...) self.manager:emit("release", ...) end, input)
	end

	function InputSystem:keypressed(key)
		input:keypressed(key)
	end

	function InputSystem:keyreleased(key)
		input:keyreleased(key)
	end

return InputSystem