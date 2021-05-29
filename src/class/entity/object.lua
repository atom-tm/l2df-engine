--- Object entity. Inherited from @{l2df.class.entity|l2df.class.Entity} class.
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
local Collision = core.import 'class.component.collision'
local Transform = core.import 'class.component.transform'

local Object = Entity:extend({ name = 'object' })

	--- Object initialization. Components:
	-- @{l2df.class.component.transform|Transform},
	-- @{l2df.class.component.frames|Frames},
	-- @{l2df.class.component.states|States},
	-- @{l2df.class.component.physix|Physix},
	-- @{l2df.class.component.collision|Collision},
	-- @{l2df.class.component.render|Render}.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt=false] boolean kwargs.hidden  Initial object hidden state.
    function Object:init(kwargs)
        self.data.hidden = kwargs.hidden or false
        self:addComponent(Transform)
        self:addComponent(Frames, kwargs)
        self:addComponent(States, kwargs)
        self:addComponent(Physix, kwargs)
        self:addComponent(Collision, kwargs)
        self:addComponent(Render, kwargs)
    end

return Object
