--- Component class
-- @classmod l2df.core.class.component
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Class = core.import 'core.class'

local Component = Class:extend()

	function Component:init()
		-- pass
	end

	function Component:added(entity, vars)
		-- pass
	end

	function Component:removed(entity, vars)
		-- pass
	end

return Component