local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'core.class.component'
local CTransform = core.import 'core.class.transform'
local helper = core.import 'helper'
local Event = core.import 'core.manager.event'

local stack = { }

local Transform = Component:extend({ unique = true })

    function Transform:init()
        self.entity = nil
        self.vars = nil
        self.x = 0
        self.y = 0
        self.z = 0
    end

    function Transform:added(entity, vars)
        if not entity then return false end
        self.entity = entity
        self.vars = vars

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0
        vars.scalex = vars.scalex or 1
        vars.scaley = vars.scaley or 1

        vars.dx = vars.dx or 0
        vars.dy = vars.dy or 0
        vars.dz = vars.dz or 0
        vars.dr = vars.dr or 0

        self.transform = CTransform:new()
    end

    function Transform:getReal()
        local m = {
            { self.x },
            { self.y },
            { self.z }
        }
        m = helper.mulMatrix(m, self.transform.matrix)
        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0

        return m[1][1], m[2][1], m[3][1]
    end

    function Transform:update()

    end

    function Transform:printReal()
        self.vars.x = 10
        self.vars.y = 0
        self.vars.z = 0
        x,y,z = self:getReal()
        print('x:', x)
        print('y:', y)
        print('z:', z)
    end

    function Transform:push()
        stack[#stack + 1] = nil
    end

    function Transform:pop()
        stack[#stack] = nil
    end

return Transform