local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Class = core.import 'core.class'

local Frame = Class:extend({ name = 'frame' })

	function Frame:init(kwargs, id, name)
        self.vars = { }

        self.vars.pic = kwargs.pic
        self.vars.states = kwargs.states or { kwargs.state }
        self.vars.dx = kwargs.dx
        self.vars.dy = kwargs.dy
        self.vars.dz = kwargs.dz
        self.vars.dr = kwargs.dr

        self.id = id
        self.next = kwargs.next
        self.wait = kwargs.wait
    end

return Frame