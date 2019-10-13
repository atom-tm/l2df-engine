local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Entity = core.import 'core.class.entity'
local Render = core.import 'core.class.component.render'
local Frames = core.import 'core.class.component.frames'
local States = core.import 'core.class.component.states'
local Print = core.import 'core.class.component.print'
local Transform = core.import 'core.class.component.transform'
local Physix = core.import 'core.class.component.physix'

local Object = Entity:extend({ name = 'object' })

    function Object:init(kwargs)
        self.vars.x = kwargs.x or 0
        self.vars.y = kwargs.y or 0
        self.vars.z = kwargs.z or 0
        self.vars.r = math.rad(kwargs.r or 0)
        self.vars.scalex = kwargs.scalex or 1
        self.vars.scaley = kwargs.scaley or 1
        self.vars.pic = kwargs.pic or 1
        self.vars.hidden = kwargs.hidden or false
        self:addComponent(Transform())
        self:addComponent(Physix())
        self:addComponent(Render(), kwargs.sprites)
        self:addComponent(Frames(), 1, kwargs.nodes)
        self:addComponent(States())
    end

return Object