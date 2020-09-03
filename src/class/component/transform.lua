--- Transform component
-- @classmod l2df.class.component.transform
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local Component = core.import 'class.component'
local CTransform = core.import 'class.transform'
local Event = core.import 'manager.event'

local stack = { CTransform:new() }

local Transform = Component:extend({ unique = true, ignore_postlift = true })

    function Transform:added(obj, kwargs)
        if not obj then return false end

        local data = obj.data
        kwargs = kwargs or { }

        data.x = kwargs.x or data.x or 0
        data.y = kwargs.y or data.y or 0
        data.z = kwargs.z or data.z or 0
        data.r = kwargs.r and math.rad(kwargs.r) or data.r or 0

        data.facing = kwargs.facing or data.facing or 1
        data.scalex = kwargs.scalex or data.scalex or 1
        data.scaley = kwargs.scaley or data.scaley or 1
        data.scalez = kwargs.scalez or data.scalez or 1
        data.centerx = kwargs.centerx or data.centerx or 0
        data.centery = kwargs.centery or data.centery or 0

        data.globalX = data.globalX or 0
        data.globalY = data.globalY or 0
        data.globalZ = data.globalZ or 0
        data.globalR = data.globalR or 0

        data.globalScaleX = data.globalScaleX or 1
        data.globalScaleY = data.globalScaleY or 1
        data.globalScaleZ = data.globalScaleZ or 1
    end

    function Transform:update(obj)
        local data = obj.data
        local m = stack[#stack]:vector(data.x, data.y, data.z)
        data.globalX, data.globalY, data.globalZ = m[1][1], m[2][1], m[3][1]

        data.globalScaleX = data.scalex * stack[#stack].sx
        data.globalScaleY = data.scaley * stack[#stack].sy
        data.globalScaleZ = data.scalez * stack[#stack].sz

        data.globalR = data.r + stack[#stack].r
    end

    function Transform:liftdown(obj)
        local v = obj.data
        local transform = CTransform:new(v.x, v.y, v.z, v.scalex * v.facing, v.scaley, v.scalez, v.r, v.centerx, v.centery)
        transform:append(stack[#stack])
        stack[#stack + 1] = transform
    end

    function Transform:liftup(obj)
        stack[#stack] = nil
    end

return Transform