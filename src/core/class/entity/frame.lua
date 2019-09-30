local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Class = core.import 'core.class'

local Frame = Class:extend({ name = 'frame' })

	function Frame:init(kwargs, id, name)
        self.vars = { }

        self.vars.pic = kwargs.pic

        self.id = id or kwargs.id
        self.next = kwargs.next
        self.wait = kwargs.wait

        print(self.id, name)
	end

return Frame