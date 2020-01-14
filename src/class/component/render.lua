--- Render component
-- @classmod l2df.class.component.render
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require((...):match('(.-)class.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local Event = core.import 'manager.event'
local RenderManager = core.import 'manager.render'
local ResourceManager = core.import 'manager.resource'

local ceil = math.ceil
local newQuad = love.graphics.newQuad

local Render = Component:extend({ unique = true })

    function Render:init()
        self.entity = nil
        self.ox = 0
        self.oy = 0
        self.kx = 0
        self.ky = 0
        self.color = { 1, 1, 1, 1 }
    end

    function Render:added(entity, sprites)
        if not entity then return false end

        assert(sprites and type(sprites) == 'table', 'Data entry error')
        sprites = sprites[1] and type(sprites[1]) == 'table' and sprites or { sprites }

        self.entity = entity
        local vars = entity.vars

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0

        vars.scaleX = vars.scaleX or 1
        vars.scaleY = vars.scaleY or 1

        vars.centerX = vars.centerX or 0
        vars.centerY = vars.centerY or 0

        -- vars.facing = vars.facing or 1

        vars.hidden = vars.hidden or false
        vars.pic = vars.pic or 1

        self.pics = { }
        for i = 1, #sprites do
            self:addSprite(sprites[i])
        end
    end


    --- Функция добавляет новый спрайт лист объекту
    -- @param mixed sprite
    function Render:addSprite(sprite)

        --[[
            res - ссылка на ресурс спрайт-листа
            w,h - ширина и высота одной ячейки
            x,y - количество ячеек в спрай-листе
            s - ячейка с которой начнётся считывание спрайтов
            f - ячейка на которой закончится считывание спрайтов
            ox, oy - смещение ячеек в листе
        ]]

        sprite.res = sprite.res or sprite[1] or nil
        sprite.w = sprite.w or sprite[2] or nil
        sprite.h = sprite.h or sprite[3] or nil

        if not (sprite.w and sprite.h) then
            print('[Ex] It does not specify the width and height of sprites', sprite.res)
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
        sprite.ord = sprite.ord or sprite[10] or #self.pics

        local num = 0
        for y = 1, sprite.y do
            for x = 1, sprite.x do
                num = num + 1
                if (sprite.s <= num) and (num <= sprite.f) then
                    self.pics[sprite.ord + (num - sprite.s) + 1] = false
                end
            end
        end

        if not ResourceManager:loadAsync(sprite.res, function (id, img)
            local num = 0
            for y = 1, sprite.y do
                for x = 1, sprite.x do
                    num = num + 1
                    if (sprite.s <= num) and (num <= sprite.f) then
                        self.pics[sprite.ord + (num - sprite.s) + 1] = {
                            sprite.res,
                            newQuad((x-1) * sprite.w + sprite.ox, (y-1) * sprite.h + sprite.oy, sprite.w, sprite.h, img:getDimensions())
                        }
                    end
                end
            end
        end) then
            print('[Ex] Data error', sprite.res)
            return
        end
    end

    function Render:postUpdate(dt, islast)
        if not (self.entity and islast) then return end

        local vars = self.entity.vars
        local pic = self.pics[vars.pic]
        if not vars.hidden and pic then
            RenderManager:add({
                object = ResourceManager:get(pic[1]),
                quad = pic[2],
                index = vars.globalZ or vars.z,
                x = vars.globalX or vars.x,
                y = vars.globalY or vars.y,
                r = vars.globalR or vars.r,
                sx = vars.facing * (vars.globalScaleX or vars.scaleX),
                sy = vars.globalScaleY or vars.scaleY,
                ox = self.ox + vars.centerX,
                oy = self.oy + vars.centerY,
                kx = self.kx,
                ky = self.ky,
                color = self.color
            })
        end
    end

return Render