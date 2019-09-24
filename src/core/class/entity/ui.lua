local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local Entity = core.import "core.class.entity"
local Render = core.import "core.class.component.render"
local Frames = core.import "core.class.component.frames"
local States = core.import "core.class.component.states"

local UI = Entity:extend()

    UI.Image = UI:extend()
    function UI.Image:init(sprites, x, y)
    	self.vars.x = x
    	self.vars.y = y
        self:addComponent(Render(), sprites)
    end

    UI.Animation = UI.Image:extend()
    function UI.Animation:init(sprites, x, y, frames)
        self:super(sprites, x, y)
        self:addComponent(Frames(), 1, frames)
        self:addComponent(States())
    end

return UI