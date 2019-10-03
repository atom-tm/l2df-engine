local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Class = core.import 'core.class'

local Transform = Class:extend()

	function Transform:init(x, y, z)
		self.matrix = {
			{ 1, 0, 0, 0 },
			{ 0, 1, 0, 0 },
			{ 0, 0, 1, 0 },
			{ 0, 0, 0, 1 },
		}
		self:set(x, y, z)
	end

	function Transform:set(x, y, z)
		self.x = x or 0
		self.y = y or 0
		self.z = z or 0
	end

return Transform