--- Transform component
-- @classmod l2df.core.class.component.transform
-- @author Kasai
-- @copyright Atom-TM 2019

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
    end

    function Transform:added(entity, vars)
        if not entity then return false end
        self.entity = entity
        self.vars = vars

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0

        vars.globalX = vars.globalX or 0
        vars.globalY = vars.globalY or 0
        vars.globalZ = vars.globalZ or 0

        vars.dx = vars.dx or 0
        vars.dy = vars.dy or 0
        vars.dz = vars.dz or 0

        vars.globalScaleX = vars.globalScaleX or 1
        vars.globalScaleY = vars.globalScaleY or 1
        vars.globalScaleZ = vars.globalScaleZ or 1
        vars.globalR = vars.globalR or 0
        vars.r = vars.r or 0
        vars.dr = vars.dr or 0

        vars.scaleX = vars.scaleX or 1
        vars.scaleY = vars.scaleY or 1
        vars.scaleZ = vars.scaleZ or 1
        vars.facing = vars.facing or 1

        vars.centerX = vars.centerX or 0
        vars.centerY = vars.centerY or 0
    end

    function Transform:update(dt)
        self:set(dt)
    end


    function Transform:set(dt)
        local vars = self.vars

        vars.x = vars.x + vars.dx * dt
        vars.y = vars.y + vars.dy * dt
        vars.z = vars.z + vars.dz * dt

        vars.dx = 0
        vars.dy = 0
        vars.dz = 0

        local m = stack[#stack]:vector(vars.x, vars.y, vars.z)
        vars.globalX, vars.globalY, vars.globalZ = m[1][1], m[2][1], m[3][1]

        vars.globalScaleX = vars.scaleX * stack[#stack].sx
        vars.globalScaleY = vars.scaleY * stack[#stack].sy
        vars.globalScaleZ = vars.scaleZ * stack[#stack].sz

        vars.globalR = vars.r + stack[#stack].r
    end

    function Transform:push()
        local v = self.vars
        local transform = CTransform:new(v.x, v.y, v.z, v.scaleX * v.facing, v.scaleY, v.scaleZ, v.r, v.centerX, v.centerY)
        transform:append(stack[#stack])
        stack[#stack + 1] = transform
    end

    function Transform:pop()
        stack[#stack] = nil
    end

    function Transform:removed(entity, vars)
        vars.globalScaleX = nil
        vars.globalScaleY = nil
        vars.globalScaleZ = nil
        vars.globalR = nil
    end

return Transform