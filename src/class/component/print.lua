--- Print component
-- @classmod l2df.class.component.print
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local RenderManager = core.import 'manager.render'
local ResourceManager = core.import 'manager.resource'

local loveNewFont = love.graphics.newFont

local Print = Component:extend({ unique = false })

    --- Init
    -- @param table kwargs
    function Print:init()
        self.entity = nil
    end

    --- Set params for printing
    -- @param table kwargs
    function Print:set(kwargs)
        if not self.entity then return false end
        local vars = self.entity.vars
        kwargs = kwargs or { }

        vars[self].text = kwargs.text or self.text or ''

        if type(kwargs.font) == 'number' then
            vars[self].font = loveNewFont(kwargs.font)
        elseif kwargs.font and kwargs.font.typeOf and kwargs.font:typeOf('Font') then
            vars[self].font = kwargs.font
        else
            vars[self].font = loveNewFont()
        end

        vars[self].limit = kwargs.limit or vars[self].font:getWidth(vars[self].text)

        vars[self].color = kwargs.color and {
            (kwargs.color[1] or 255) / 255,
            (kwargs.color[2] or 255) / 255,
            (kwargs.color[3] or 255) / 255,
            (kwargs.color[4] or 255) / 255 }
        or { 1,1,1,1 }


        --[[if type(kwargs.font) == 'number' then
            self.font = loveNewFont(kwargs.font)
        elseif kwargs.font and kwargs.font.typeOf and kwargs.font:typeOf('Font') then
            vars[self].font = kwargs.font
        else
            vars[self].font = loveNewFont()
        end
        self.ox = kwargs.ox or self.ox or 0
        self.oy = kwargs.oy or self.oy or 0
        self.kx = kwargs.kx or self.kx or 0
        self.ky = kwargs.ky or self.ky or 0
        self.sx = kwargs.sx or self.sx or 1
        self.sy = kwargs.sy or self.sy or 1
        self.color = kwargs.color and { (kwargs.color[1] or 255) / 255, (kwargs.color[2] or 255) / 255, (kwargs.color[3] or 255) / 255, (kwargs.color[4] or 255) / 255 } or { 1,1,1,1 }]]
    end

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity entity
    function Print:added(entity, kwargs)
        if not entity then return false end
        self.entity = entity
        local vars = entity.vars
        vars[self] = {}

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0

        vars.scaleX = vars.scaleX or 1
        vars.scaleY = vars.scaleY or 1

        vars.hidden = vars.hidden or false

        self:set(kwargs)
    end

    --- Post-update event
    function Print:postUpdate()
        if not self.entity then return end
        local vars = self.entity.vars
        if not vars.hidden then
            RenderManager:add({
                text = vars[self].text,
                font = vars[self].font,
                limit = vars[self].limit,

                z = vars.globalZ or vars.z,
                x = vars.globalX or vars.x,
                y = vars.globalY or vars.y,
                r = vars.r,

                color = vars[self].color,

            })
        end
    end

return Print