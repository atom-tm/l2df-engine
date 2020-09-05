--- Scene entity
-- @classmod l2df.class.entity.scene
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Entity = core.import 'class.entity'
local Storage = core.import 'class.storage'
local Renderer = core.import 'manager.render'

local Scene = Entity:extend({ name = 'scene' })

	function Scene:init(kwargs)
		kwargs = kwargs or { }
		local layers = kwargs.layers or { }
		for i = 1, #layers do
			Renderer:addLayer(layers[i][1], layers[i])
		end
		self.nodes = Storage:new()
		self.active = kwargs.active and true or false
		self:attachMultiple(kwargs.nodes)
	end

return Scene