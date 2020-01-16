--- Kind class
-- @classmod l2df.class.kind
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Kind works only with l2df v1.0 and higher')

local Class = core.import 'class'

local Kind = Class:extend()

    function Kind.filter(entity)
    	return true
    end

    function Kind:init()
        -- pass
    end

    function Kind:trigger(e1, e2, itr)
        -- pass
    end

return Kind