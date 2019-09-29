local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Class = core.import 'core.class'

local Reader = Class:extend()

	--- Reader initialization
	function Reader:init(obj)
		assert(type(obj) == 'table', 'Reader works only with tables')
		self.object = obj
		self.current = false
		self.carriage = 0
	end

	--- Reader next item
	function Reader:next()
		self.carriage = self.carriage + 1
		self.current = self.object[self.carriage]
		return self.current or false
	end

return Reader