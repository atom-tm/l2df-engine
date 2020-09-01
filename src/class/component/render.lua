--- Render component
-- @classmod l2df.class.component.render
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require((...):match('(.-)class.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'
local Physix = core.import 'class.component.physix'

local log = core.import 'class.logger'
local Event = core.import 'manager.event'
local RenderManager = core.import 'manager.render'
local ResourceManager = core.import 'manager.resource'

local ceil = math.ceil
local newQuad = love.graphics.newQuad

local greenColor = { 0, 1, 0, 0.3 }
local yellowColor = { 0, 1, 1, 0.5 }
local redColor = { 1, 0, 0, 0.5 }

local Render = Component:extend({ unique = true })

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity obj
    -- @param table sprites
    function Render:added(obj, sprites, kwargs)
        if not obj then return false end

        local data = obj.data
        local odata = self:data(obj)

        kwargs = kwargs or { }

        odata.pics = { }
        if not (sprites and type(sprites) == 'table') then
            log:warn 'Created object without render support'
            return obj:removeComponent(self)
        end
        sprites = sprites[1] and type(sprites[1]) == 'table' and sprites or { sprites }

        data.x = data.x or 0
        data.y = data.y or 0
        data.z = data.z or 0
        data.r = data.r or 0

        data.scalex = data.scalex or 1
        data.scaley = data.scaley or 1

        data.centerx = data.centerx or 0
        data.centery = data.centery or 0

        data.facing = data.facing or 1

        data.hidden = data.hidden or false
        data.pic = data.pic or kwargs.pic or 1

        odata.color = kwargs.color and {
            (kwargs.color[1] or 255) / 255,
            (kwargs.color[2] or 255) / 255,
            (kwargs.color[3] or 255) / 255,
            (kwargs.color[4] or 255) / 255
        } or { 1,1,1,1 }

        for i = 1, #sprites do
            self:addSprite(obj, sprites[i])
        end
    end


    --- Add new sprite-list
    -- @param table sprite
    function Render:addSprite(obj, sprite)
        local data = obj.data

        --[[
            res - ссылка на ресурс спрайт-листа
            w,h - ширина и высота одной ячейки
            x,y - количество ячеек в спрай-листе
            s - ячейка с которой начнётся считывание спрайтов
            f - ячейка на которой закончится считывание спрайтов
            ox, oy - смещение ячеек в листе
        ]]

        local odata = self:data(obj)

        sprite.res = sprite.res or sprite[1] or nil
        sprite.w = sprite.w or sprite[2] or nil
        sprite.h = sprite.h or sprite[3] or nil

        if not (sprite.w and sprite.h) then
            log:error('Missing width and height for: %s', sprite.res)
            return
        end

        sprite.x = sprite.x or sprite[4] or 1
        sprite.y = sprite.y or sprite[5] or 1

        local count = sprite.x * sprite.y
        if (count) == 0 then return end

        sprite.s = sprite.s or sprite[6] or 1
        sprite.f = sprite.f or sprite[7] or count
        sprite.ox = sprite.ox or sprite[8] or 0
        sprite.oy = sprite.oy or sprite[9] or 0
        sprite.ord = sprite.ord or sprite[10] or #odata.pics

        local num = 0
        for y = 1, sprite.y do
            for x = 1, sprite.x do
                num = num + 1
                if (sprite.s <= num) and (num <= sprite.f) then
                    odata.pics[sprite.ord + (num - sprite.s) + 1] = false
                end
            end
        end

        if not ResourceManager:loadAsync(sprite.res, function (id, img)
            local num = 0
            for y = 1, sprite.y do
                for x = 1, sprite.x do
                    num = num + 1
                    if (sprite.s <= num) and (num <= sprite.f) then
                        odata.pics[sprite.ord + (num - sprite.s) + 1] = {
                            sprite.res,
                            newQuad((x-1) * sprite.w + sprite.ox, (y-1) * sprite.h + sprite.oy, sprite.w, sprite.h, img:getDimensions())
                        }
                    end
                end
            end
        end) then
            log:error('Data error: %s', sprite.res)
            return
        end
    end

    --- Post-update event
    -- @param number dt
    -- @param boolean islast
    function Render:postupdate(obj, dt, islast)
        if not (obj and islast) then return end

        local data = obj.data
        if data.hidden then return end
        local pic = data[self].pics[data.pic]
        if pic then
            RenderManager:add({
                object = ResourceManager:get(pic[1]),
                quad = pic[2],
                x = data.globalX or data.x,
                y = data.globalY or data.y,
                z = data.globalZ or data.z,
                r = data.globalR or data.r,
                sx = data.facing * (data.globalScaleX or data.scalex),
                sy = data.globalScaleY or data.scaley,
                ox = data.centerx,
                oy = data.centery,
                color = data[self].color
            })
        end

        if not RenderManager.DEBUG then return end

        RenderManager:add({
            circle = 'fill',
            x = data.globalX or data.x,
            y = data.globalY or data.y,
            z = data.globalZ or data.z,
            color = data[self].color
        })

        local bodies, body = data.bodies
        if bodies then
            for i = 1, #bodies do
                body = bodies[i]
                RenderManager:add({
                    cube = true,
                    x = (data.globalX or data.x) + body.x,
                    y = (data.globalY or data.y) - body.y,
                    z = (data.globalZ or data.z) + body.z,
                    w = body.w,
                    h = body.h,
                    d = body.d,
                    color = greenColor
                })
            end
        end

        local itrs, itr = data.itrs
        if itrs then
            for i = 1, #itrs do
                itr = itrs[i]
                RenderManager:add({
                    cube = true,
                    x = (data.globalX or data.x) + itr.x * data.facing + itr.w * (data.facing - 1) / 2,
                    y = (data.globalY or data.y) - itr.y,
                    z = (data.globalZ or data.z) + itr.z,
                    w = itr.w,
                    h = itr.h,
                    d = itr.d,
                    color = redColor
                })
            end
        end
    end

return Render
