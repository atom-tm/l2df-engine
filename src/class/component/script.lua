--- Script class
-- @classmod l2df.class.component
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require((...):match('(.-)class.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local Script = Component:extend({ unique = false })

    --- Init
	function Script:init()
        self.entity = nil
	end

    --- Script added to l2df.class.entity
    -- @param l2df.class.entity entity
    -- @param function function
	function Script:added(entity, func, trigger)
		func = type(func) == "function" and func or function() end
        if trigger then
            self[trigger] = func
        else
            self.update = func
        end
	end

return Script