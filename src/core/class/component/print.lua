--- Print component
-- @classmod l2df.core.class.component.print
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'core.class.component'

local Event = core.import 'core.manager.event'
local RenderManager = core.import 'core.manager.render'
local ResourceManager = core.import 'core.manager.resource'

local loveNewFont = love.graphics.newFont

local Print = Component:extend({ unique = false })

    function Print:init(kwargs)
        self.entity = nil
        self:set(kwargs)
    end

    function Print:set(kwargs)
        kwargs = kwargs or { }
        if type(kwargs.font) == 'number' then
            self.font = loveNewFont(kwargs.font)
        elseif kwargs.font and kwargs.font.typeOf and kwargs.font:typeOf('Font') then
            self.font = kwargs.font
        else
            self.font = loveNewFont()
        end
        self.text = kwargs.text or self.text or ''
        self.limit = kwargs.limit or self.font:getWidth(self.text)
        self.align = kwargs.align or self.align or 'left'
        self.ox = kwargs.ox or self.ox or 0
        self.oy = kwargs.oy or self.oy or 0
        self.kx = kwargs.kx or self.kx or 0
        self.ky = kwargs.ky or self.ky or 0
        self.sx = kwargs.sx or self.sx or 1
        self.sy = kwargs.sy or self.sy or 1
        self.color = kwargs.color and { (kwargs.color[1] or 255) / 255, (kwargs.color[2] or 255) / 255, (kwargs.color[3] or 255) / 255, (kwargs.color[4] or 255) / 255 } or { 1,1,1,1 }
    end

    function Print:added(entity, vars)
        if not entity then return false end
        self.entity = entity
        self.vars = vars
        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0
        vars.hidden = vars.hidden or false
    end

    function Print:postUpdate()
        if not self.vars.hidden then
            RenderManager:add({
                text = self.text,
                font = self.font,
                index = self.vars.globalZ or self.vars.z,
                x = self.vars.globalX or self.vars.x,
                y = self.vars.globalY or self.vars.y,
                r = self.vars.r,
                limit = self.limit,
                align = self.align,
                ox = self.ox,
                oy = self.oy,
                sx = self.vars.globalScaleX or 1 * self.sx,
                sy = self.vars.globalScaleY or 1 * self.sy,
                kx = self.kx,
                ky = self.ky,
                color = self.color,
            })
        end
    end

return Print