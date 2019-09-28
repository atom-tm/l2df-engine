local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local Entity = core.import "core.class.entity"
local Render = core.import "core.class.component.render"
local Frames = core.import "core.class.component.frames"
local States = core.import "core.class.component.states"
local Print = core.import 'core.class.component.print'

local UI = Entity:extend()

    function UI:init(desc)
        self.vars.x = desc.x or 0
        self.vars.y = desc.y or 0
        self.vars.z = desc.z or 1
        self.vars.scalex = desc.scalex or 1
        self.vars.scaley = desc.scaley or 1
    end

    UI.Image = UI:extend()
    function UI.Image:init(desc)
        self:super(desc)
        self:addComponent(Render(), desc.sprites)
    end

    UI.Text = UI:extend()
    function UI.Text:init(desc)
        self:super(desc)
        self:addComponent(Print(desc))
    end

    UI.Animation = UI.Image:extend()
    function UI.Animation:init(desc)
        self:super(desc)
        self:addComponent(Frames(), 1, frames)
        self:addComponent(States())
    end

return UI