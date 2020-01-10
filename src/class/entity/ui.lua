--- UI entities module
-- @classmod l2df.core.class.entity.ui
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Entity = core.import 'class.entity'
local Render = core.import 'class.component.render'
local Frames = core.import 'class.component.frames'
local States = core.import 'class.component.states'
local Print = core.import 'class.component.print'
local Transform = core.import 'class.component.transform'
local Physix = core.import 'class.component.physix'

local UI = Entity:extend()

    function UI:init(kwargs)
        self.vars.x = kwargs.x or 0
        self.vars.y = kwargs.y or 0
        self.vars.z = kwargs.z or 0
        self.vars.r = math.rad(kwargs.r or 0)
        self.vars.scalex = kwargs.scalex or 1
        self.vars.scaley = kwargs.scaley or 1
        self.vars.pic = kwargs.pic or 1
        self.vars.hidden = kwargs.hidden or false
        self:addComponent(Transform())
    end

    UI.Image = UI:extend({ name = 'image' })
    function UI.Image:init(kwargs)
        self:super(kwargs)
        self:addComponent(Render(), kwargs.sprites)
    end

    UI.Text = UI:extend({ name = 'text' })
    function UI.Text:init(kwargs)
        self:super(kwargs)
        self:addComponent(Print(kwargs))
    end

    UI.Animation = UI:extend({ name = 'animation' })
    function UI.Animation:init(kwargs)
        self:super(kwargs)
        self:addComponent(Render(), kwargs.sprites)
        self:addComponent(Frames(), 1, kwargs.nodes)
    end

return setmetatable({ UI.Image, UI.Animation, UI.Text }, { __index = UI })