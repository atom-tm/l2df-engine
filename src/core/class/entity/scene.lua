local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Entity = core.import 'core.class.entity'
local Print = core.import 'core.class.component.print'

local Scene = Entity:extend({ name = 'scene' })

	function Scene:init(kwargs)
		kwargs = kwargs or { }
		kwargs.nodes = kwargs.nodes or { }
		self:attachMultiple(kwargs.nodes)
	end

return Scene