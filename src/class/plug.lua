--- Plug class. It is used as a dummy object for async operations. Inherited from @{l2df.class|l2df.Class}.
-- @classmod l2df.class.plug
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Plugs works only with l2df v1.0 and higher')

local Class = core.import 'class'

local Plug = Class:extend()

	--- Init. Does nothing.
    function Plug:init()

    end

return Plug