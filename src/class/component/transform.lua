--- Transform component.
-- <p>It controls and handles entity's position, rotation and scale and also processes its modifications.</p>
-- <p>Inherited from @{l2df.class.component|l2df.class.Component} class.</p>
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

    --- Entity's global X position in space of the screen (includes parent's transformation).
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.globalX

    --- Entity's global Y position in space of the screen (includes parent's transformation).
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.globalY

    --- Entity's global Z position in space of the screen (includes parent's transformation).
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.globalZ

    --- Entity's global rotation in radians (includes parent's transformation). Performed around Z axis in space of the display.
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.globalR

    --- Entity's global X scale in space of the screen (includes parent's transformation).
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.globalScalex

    --- Entity's global Y scale in space of the screen (includes parent's transformation).
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.globalScaley

    --- Entity's global Z scale in space of the screen (includes parent's transformation).
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.globalScalez

    --- Entity's X position in space of the parent entity.
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.x

    --- Entity's Y position in space of the parent entity.
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.y

    --- Entity's Z position in space of the parent entity.
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.z

    --- Entity's rotation in radians in space of the parent entity. Performed around Z axis in space of the display.
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.r

    --- Entity's X scale in space of the parent entity.
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.scalex

    --- Entity's Y scale in space of the parent entity.
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.scaley

    --- Entity's Z scale in space of the parent entity.
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.scalez

    --- Entity's origin X position in space of the parent entity.
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.centerx

    --- Entity's origin Y position in space of the parent entity.
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.centery

    --- Entity's X orientation (not a whole axis). Can be 1 or -1 (mirrored).
    -- To access use @{l2df.class.component.data|Transform:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field number Transform.data.facing

    --- Component was added to @{l2df.class.entity|Entity} event.
    -- Adds `"transform"` key to the @{l2df.class.entity.C|Entity.C} table.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @param[opt] table kwargs  Keyword arguments.
    -- @param[opt] {l2df.class.component.render.Sprite,...} kwargs.sprites  Array of sprites to be added with @{l2df.class.component.render.addSprite|Render:addSprite()} method.
    -- @param[opt=0] number kwargs.x  Entity's X position.
    -- @param[opt=0] number kwargs.y  Entity's Y position.
    -- @param[opt=0] number kwargs.z  Entity's Z position.
    -- @param[opt=0] number kwargs.r  Entity's rotation in radians. Performed around Z axis in space of the display.
    -- @param[opt=1] number kwargs.facing  Entity's X orientation (not a whole axis). Can be 1 or -1 (mirrored).
    -- @param[opt=1] number kwargs.scalex  Entity's X scale.
    -- @param[opt=1] number kwargs.scaley  Entity's Y scale.
    -- @param[opt=1] number kwargs.scalez  Entity's Z scale.
    -- @param[opt=0] number kwargs.centerx  Entity's origin X position.
    -- @param[opt=0] number kwargs.centery  Entity's origin Y position.
    function Transform:added(obj, kwargs)
        if not obj then return false end

        local data = obj.data
        kwargs = kwargs or { }

        obj.C.transform = self:wrap(obj)

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

    --- Component was removed from @{l2df.class.entity|Entity} event.
    -- Removes `"transform"` key from @{l2df.class.entity.C|Entity.C} table.
    -- @param l2df.class.entity obj  Entity's instance.
    function Transform:removed(obj)
        self.super.removed(self, obj)
        obj.C.transform = nil
    end

    --- Component update event handler.
    -- Calculates "globals": position, rotation, scale (see Fields).
    -- @param l2df.class.entity obj  Entity's instance.
    function Transform:update(obj)
        local data = obj.data
        local m = stack[#stack]:vector(data.x, data.y, data.z)
        data.globalX, data.globalY, data.globalZ = m[1][1], m[2][1], m[3][1]

        data.globalScaleX = data.scalex * stack[#stack].sx
        data.globalScaleY = data.scaley * stack[#stack].sy
        data.globalScaleZ = data.scalez * stack[#stack].sz

        data.globalR = data.r + stack[#stack].r
    end

    --- Component liftdown event handler.
    -- Used to generate @{l2df.class.transform|Transformation object} for the current state of the entity and apply it to parent's transformation.
    -- It's an important step before calculating "globals": position, rotation and scale (see Fields).
    -- @param l2df.class.entity obj  Entity's instance.
    function Transform:liftdown(obj)
        local v = obj.data
        local transform = CTransform:new(v.x, v.y, v.z, v.scalex * v.facing, v.scaley, v.scalez, v.r, v.centerx, v.centery)
        transform:append(stack[#stack])
        stack[#stack + 1] = transform
    end

    --- Component liftup event handler.
    -- Frees memory allocated by @{l2df.class.component.transform.liftdown|Transform:liftdown()}.
    -- @param l2df.class.entity obj  Entity's instance.
    function Transform:liftup(obj)
        stack[#stack] = nil
    end

return Transform