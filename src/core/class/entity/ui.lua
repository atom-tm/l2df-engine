local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local Entity = core.import "core.class.entity"
local Render = core.import "core.class.component.render"

local UI = Entity:extend()

    function UI:init(sprites, x, y)
    	self.x = x
    	self.y = y

        self:addComponent(Render(), sprites)
    end

return UI