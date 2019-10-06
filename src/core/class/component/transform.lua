local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'core.class.component'
local CTransform = core.import 'core.class.transform'
local helper = core.import 'helper'
local Event = core.import 'core.manager.event'

local stack = { CTransform:new() }

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
        vars.scalez = vars.scalez or 1
        vars.facing = vars.facing or 1

        vars.dx = vars.dx or 0
        vars.dy = vars.dy or 0
        vars.dz = vars.dz or 0
        vars.dr = vars.dr or 0

        self.x = vars.x
        self.y = vars.y
        self.z = vars.z

        self.transform = CTransform:new()
    end

    function Transform:update()
        local vars = self.vars
        self.transform = CTransform:new()

        self.x = self.x + vars.dx
        self.y = self.y + vars.dy
        self.z = self.z + vars.dz
        vars.dx = 0
        vars.dy = 0
        vars.dz = 0

        self.transform:scale(vars.scalex * vars.facing, vars.scaley, vars.scalez)
        self.transform:translate(self.x, self.y, self.z)
        self.transform:rotate(vars.r)

        vars.x, vars.y, vars.z = self:getReal()
    end

    function Transform:getReal()
        local m = stack[#stack]:vector(self.x, self.y, self.z)
        return m[1][1], m[2][1], m[3][1]
    end

    function Transform:push()
        local t = CTransform:new()
        t = stack[#stack] and t:append(stack[#stack]) and t or t
        t:append(self.transform)
        stack[#stack + 1] = t
    end

    function Transform:pop()
        stack[#stack] = nil
    end

return Transform