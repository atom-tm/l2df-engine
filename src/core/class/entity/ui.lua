local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local Entity = core.import "core.class.entity"

local Draw = core.import "core.class.component.draw"

local UI = Entity:extend()

    function UI:init(res, x, y)
        self.x = x
        self.y = y
        self:addComponent(Draw, res)
    end

return UI