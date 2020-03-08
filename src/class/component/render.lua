--- Render component
-- @classmod l2df.class.component.render
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require((...):match('(.-)class.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local log = core.import 'class.logger'
local Event = core.import 'manager.event'
local RenderManager = core.import 'manager.render'
local ResourceManager = core.import 'manager.resource'

local ceil = math.ceil
local newQuad = love.graphics.newQuad

local greenColor = { 0, 1, 0, 0.5 }
local redColor = { 1, 0, 0, 0.5 }

local Render = Component:extend({ unique = true })

    --- Init
    function Render:init()
        self.entity = nil
    end

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity entity
    -- @param table sprites
    function Render:added(entity, sprites, kwargs)
        if not entity then return false end

        self.entity = entity
        local vars = entity.vars
        vars[self] = { }

        kwargs = kwargs or { }

        vars[self].pics = { }
        if not (sprites and type(sprites) == 'table') then
            log:warn 'Created object without render support'
            return entity:removeComponent(self)
        end
        sprites = sprites[1] and type(sprites[1]) == 'table' and sprites or { sprites }


        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0

        vars.scaleX = vars.scaleX or 1
        vars.scaleY = vars.scaleY or 1

        vars.centerX = vars.centerX or 0
        vars.centerY = vars.centerY or 0

        vars.facing = vars.facing or 1

        vars.hidden = vars.hidden or false
        vars.pic = vars.pic or 1

        vars[self].color = kwargs.color and {
            (kwargs.color[1] or 255) / 255,
            (kwargs.color[2] or 255) / 255,
            (kwargs.color[3] or 255) / 255,
            (kwargs.color[4] or 255) / 255 }
        or { 1,1,1,1 }

        for i = 1, #sprites do
            self:addSprite(sprites[i])
        end
    end


    --- Add new sprite-list
    -- @param table sprite
    function Render:addSprite(sprite)

        local vars = self.entity.vars

        --[[
            res - ссылка на ресурс спрайт-листа
            w,h - ширина и высота одной ячейки
            x,y - количество ячеек в спрай-листе
            s - ячейка с которой начнётся считывание спрайтов
            f - ячейка на которой закончится считывание спрайтов
            ox, oy - смещение ячеек в листе
        ]]

        local entity = self.entity
        local vars = entity.vars

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
        sprite.ord = sprite.ord or sprite[10] or #vars[self].pics

        local num = 0
        for y = 1, sprite.y do
            for x = 1, sprite.x do
                num = num + 1
                if (sprite.s <= num) and (num <= sprite.f) then
                    vars[self].pics[sprite.ord + (num - sprite.s) + 1] = false
                end
            end
        end

        if not ResourceManager:loadAsync(sprite.res, function (id, img)
            local num = 0
            for y = 1, sprite.y do
                for x = 1, sprite.x do
                    num = num + 1
                    if (sprite.s <= num) and (num <= sprite.f) then
                        vars[self].pics[sprite.ord + (num - sprite.s) + 1] = {
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
    function Render:postUpdate(dt, islast)
        local entity = self.entity
        if not (entity and islast) then return end

        local vars = entity.vars
        if vars.hidden then return end

        local pic = vars[self].pics[vars.pic]
        if pic then
            RenderManager:add({
                object = ResourceManager:get(pic[1]),
                quad = pic[2],
                x = vars.globalX or vars.x,
                y = vars.globalY or vars.y,
                z = vars.globalZ or vars.z,
                r = vars.globalR or vars.r,
                sx = vars.facing * (vars.globalScaleX or vars.scaleX),
                sy = vars.globalScaleY or vars.scaleY,
                color = vars[self].color
            })
        end

        if not RenderManager.DEBUG then return end

        RenderManager:add({
            circle = 'fill',
            x = vars.globalX or vars.x,
            y = vars.globalY or vars.y,
            z = vars.globalZ or vars.z,
            color = vars[self].color
        })

        if vars.body then
            RenderManager:add({
                cube = true,
                x = (vars.globalX or vars.x) + vars.body.x,
                y = (vars.globalY or vars.y) + vars.body.y,
                z = (vars.globalZ or vars.z) + vars.body.z,
                w = vars.body.w,
                h = vars.body.h,
                l = vars.body.l,
                color = greenColor
            })
        end

        local itrs, itr = vars.itrs
        if itrs then
            for i = 1, #itrs do
                itr = itrs[i]
                RenderManager:add({
                    cube = true,
                    x = (vars.globalX or vars.x) + itr.x * vars.facing + itr.w * (vars.facing - 1) / 2,
                    y = (vars.globalY or vars.y) + itr.y,
                    z = (vars.globalZ or vars.z) + itr.z,
                    w = itr.w,
                    h = itr.h,
                    l = itr.l,
                    color = redColor
                })
            end
        end
    end

return Render