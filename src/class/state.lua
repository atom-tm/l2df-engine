--- State class
-- @classmod l2df.class.state
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'State works only with l2df v1.0 and higher')

local Class = core.import 'class'

local State = Class:extend()

	--- Init
    function State:init()
        -- pass
    end

    --- Persistent update
    -- @param l2df.class.entity entity
    -- @param table params
    function State:persistentUpdate(entity, params)
        -- pass
    end

    --- Update
    -- @param l2df.class.entity entity
    -- @param table params
    function State:update(entity, params)
        -- pass
    end

return State