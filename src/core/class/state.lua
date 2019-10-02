local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'State works only with l2df v1.0 and higher')

local Class = core.import 'core.class'

local State = Class:extend()

    function State:init()
        -- pass
    end

    function State:persistentUpdate(entity, vars)
        -- pass
    end

    function State:update(entity, vars)
        -- pass
    end

return State