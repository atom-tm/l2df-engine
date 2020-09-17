--- Map object
-- @classmod l2df.class.entity.map
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Scene = core.import 'class.entity.scene'
local Render = core.import 'class.component.render'
local Frames = core.import 'class.component.frames'
local States = core.import 'class.component.states'
local World = core.import 'class.component.physix.world'
local Transform = core.import 'class.component.transform'

local Map = Scene:extend({ name = 'map' })

	function Map:init(kwargs)
		self:super(kwargs)
		self.data.hidden = kwargs.hidden or false
		self:addComponent(Transform, kwargs)
		self:addComponent(Frames, kwargs)
		self:addComponent(States, kwargs)
		self:addComponent(Render, kwargs.sprites, kwargs)
		self:addComponent(World(), kwargs)
	end

return Map
