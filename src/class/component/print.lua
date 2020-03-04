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

    function Print:init()
        self.entity = nil
    end

    --- Set params for printing
    -- @param table kwargs
    function Print:set(kwargs)
        if not entity then return false end
        local vars = entity.vars
        kwargs = kwargs or { }

        if type(kwargs.font) == 'number' then
            vars[self].font = loveNewFont(kwargs.font)
        elseif kwargs.font and kwargs.font.typeOf and kwargs.font:typeOf('Font') then
            vars[self].font = kwargs.font
        else
            vars[self].font = loveNewFont()
        end

        vars[self].text = kwargs.text or vars[self].text or ''
        vars[self].limit = kwargs.limit or vars[self].font:getWidth(vars[self].text)
        vars[self].align = kwargs.align or  vars[self].align or 'left'
        vars[self].ox = kwargs.ox or vars[self].ox or 0
        vars[self].oy = kwargs.oy or vars[self].oy or 0
        vars[self].kx = kwargs.kx or vars[self].kx or 0
        vars[self].ky = kwargs.ky or vars[self].ky or 0
        vars[self].sx = kwargs.sx or vars[self].sx or 1
        vars[self].sy = kwargs.sy or vars[self].sy or 1
        vars[self].color = kwargs.color and { (kwargs.color[1] or 255) / 255, (kwargs.color[2] or 255) / 255, (kwargs.color[3] or 255) / 255, (kwargs.color[4] or 255) / 255 } or { 1,1,1,1 }
    end

    function Print:added(entity, kwargs)
        if not entity then return false end
        self.entity = entity
        local vars = entity.vars
        vars[self] = { }
        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0
        vars.hidden = vars.hidden or false
        self:set(kwargs)
    end

    --- Post-update event
    function Print:postUpdate()
        if not self.entity then return end

        local vars = self.entity.vars
        if not vars.hidden then
            RenderManager:add({
                text = vars.text,
                font =  vars[self].font,
                z = vars.globalZ or vars.z,
                x = vars.globalX or vars.x,
                y = vars.globalY or vars.y,
                r = vars.r,
                limit =  vars[self].limit,
                align =  vars[self].align,
                ox =  vars[self].ox,
                oy =  vars[self].oy,
                sx = vars.globalScaleX or 1 *  vars[self].sx,
                sy = vars.globalScaleY or 1 *  vars[self].sy,
                kx =  vars[self].kx,
                ky =  vars[self].ky,
                color =  vars[self].color,
            })
        end
    end

return Print