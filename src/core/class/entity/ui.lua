local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local Entity = core.import "core.class.entity"
local Render = core.import "core.class.component.render"
local Frames = core.import "core.class.component.frames"

local UI = Entity:extend()

    UI.Image = UI:extend()
    function UI.Image:init(sprites, x, y)
        self.x = x
        self.y = y
        self:addComponent(Render(), sprites)
    end

    UI.Animation = UI.Image:extend()
    function UI.Animation:init(sprites, x, y)
        self:super(sprites, x, y)
        self:addComponent(Frames(), 1, {
            { x = 5, y = 5, next = 2 },
            { x = 10, y = 10, next = 3 },
            { x = 15, y = 15, next = 4 },
            { x = 10, y = 10, next = 1 }
        })
    end

return UI