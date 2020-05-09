--- Frame class
-- @classmod l2df.class.entity.frame
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Frames works only with l2df v1.0 and higher')

local Class = core.import 'class'

local pairs = _G.pairs

local Frame = Class:extend({ name = 'frame' })

	function Frame:init(kwargs, id, keyword)
        self.id = kwargs.id or id
        self.keyword = kwargs.keyword or keyword
        self.next = kwargs.next
        self.wait = kwargs.wait or 0

        kwargs.next = nil
        kwargs.wait = nil

        self.vars = { }
        for k, v in pairs(kwargs) do
            if type(v) ~= 'table' then
                self.vars[k] = v
            end
        end

        local body = kwargs.body or false -- required for rewriting in update
        if body then
            body.x = body.x or 0
            body.y = body.y or 0
            body.z = body.z or 0
            body.w = body.w or 1
            body.h = body.h or 1
            body.l = body.l or 1
        end

        local itrs, itr = kwargs.itrs or { kwargs.itr }
        for i = 1, #itrs do
            itr = itrs[i]
            itr.x = itr.x or 0
            itr.y = itr.y or 0
            itr.z = itr.z or 0
            itr.w = itr.w or 1
            itr.h = itr.h or 1
            itr.l = itr.l or 1
        end

        self.vars.body = body
        self.vars.itrs = itrs
        self.vars.states = kwargs.states or { kwargs.state }
    end

return Frame