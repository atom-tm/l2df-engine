--- Plug class
-- @classmod l2df.class.plug
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Plugs works only with l2df v1.0 and higher')

local Class = core.import 'class'
local Plug = Class:extend()

    function Plug:init()

    end

return Plug