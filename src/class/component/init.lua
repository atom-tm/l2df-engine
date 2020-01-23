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
		-- pass
	end

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity entity
	function Component:added(entity)
		-- pass
	end

    --- Component removed from l2df.class.entity
    -- @param l2df.class.entity entity
	function Component:removed(entity)
		-- pass
	end

return Component