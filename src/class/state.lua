--- State class
-- @classmod l2df.class.state
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'State works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local Class = core.import 'class'

local State = Class:extend()

	--- Init
    function State:init(vars)
        if type(vars) == 'table' then
            helper.copyTable(vars, self)
        end
    end

    --- Persistent update
    -- @param number dt
    -- @param l2df.class.entity entity
    -- @param table params
    function State:persistentUpdate(dt, entity, params)
        -- pass
    end

    --- Update
    -- @param l2df.class.entity entity
    -- @param table params
    function State:update(entity, params)
        -- pass
    end

return State