--- Component class
-- @classmod l2df.class.component
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require((...):match('(.-)class.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Class = core.import 'class'

local Component = Class:extend()

	--- Init
	function Component:init()
		self.entity = nil
		self.__meta = nil
	end

	--- Get entity's variables proxy table
	-- @return table
	function Component:vars()
		if not self.entity then return nil end
		local vars = self.entity.vars
		if not self.__meta and vars then
			vars[self] = vars[self] or { }
			self.__meta = setmetatable({ }, {
				__index = function (_, key)
					return vars[self][key] or vars[key]
				end,
				__newindex = function (_, key, value)
					vars[self][key] = value
				end
			})
		end
		return self.__meta
	end

	--- Component added to l2df.class.entity
	-- @param l2df.class.entity entity
	function Component:added(entity)
		self.entity = entity
		self.__meta = nil
	end

	--- Component removed from l2df.class.entity
	-- @param l2df.class.entity entity
	function Component:removed(entity)
		self.entity = entity
		self.__meta = nil
	end

return Component