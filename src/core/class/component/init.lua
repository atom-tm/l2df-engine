local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Class = core.import 'core.class'
local Event = core.import 'core.manager.event'

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