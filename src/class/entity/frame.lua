--- Frame entity
-- @classmod l2df.class.entity.frame
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Class = core.import 'class'

local pairs = _G.pairs

local Frame = Class:extend({ name = 'frame' })

	function Frame:init(kwargs, id, keyword)
        self.id = id
        self.keyword = keyword
        self.next = kwargs.next
        self.wait = kwargs.wait

        kwargs.next = nil
        kwargs.wait = nil

        self.vars = { }
        for k, v in pairs(kwargs) do
            if type(v) ~= 'table' then
                self.vars[k] = v
            end
        end
        self.vars.states = kwargs.states or { kwargs.state }
    end

return Frame