--- Object entity
-- @classmod l2df.class.entity.object
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Entity = core.import 'class.entity'
local Render = core.import 'class.component.render'
local Frames = core.import 'class.component.frames'
local States = core.import 'class.component.states'
local Physix = core.import 'class.component.physix'
local Transform = core.import 'class.component.transform'

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

        self:addComponent(Frames(), 1, kwargs.nodes)
        self:addComponent(States(), kwargs)
        self:addComponent(Physix(), kwargs)
        self:addComponent(Transform())
        self:addComponent(Render(), kwargs.sprites)
    end

return Object