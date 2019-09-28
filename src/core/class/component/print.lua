local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"

local Event = core.import "core.manager.event"
local RenderManager = core.import "core.manager.render"
local ResourseManager = core.import "core.manager.resourse"

local Print = Component:extend({ unique = false })

    function Print:init(desc)
        self.entity = nil
        self:set(desc)
    end

    function Print:set(desc)
        desc = desc or { }
        desc.font = desc.font and desc.font.typeOf and desc.font:typeOf('Font') and desc.font or nil
        self.text = desc.text or self.text or ''
        self.font =  desc.font or self.font or love.graphics.newFont()
        self.limit = desc.limit or self.font:getWidth(self.text)
        self.align = desc.align or self.align or 'left'
        self.ox = desc.ox or self.ox or 0
        self.oy = desc.oy or self.oy or 0
        self.kx = desc.kx or self.kx or 0
        self.ky = desc.ky or self.ky or 0
        self.sx = desc.sx or self.sx or 1
        self.sy = desc.sy or self.sy or 1
        self.color = desc.color and { (desc.color[1] or 255) / 255, (desc.color[2] or 255) / 255, (desc.color[3] or 255) / 255, (desc.color[4] or 255) / 255 } or { 1,1,1,1 }
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

    function Print:update()
        if not self.vars.hidden then
            RenderManager:add({
                object = self.text,
                font = self.font,
                index = self.vars.z,
                x = self.vars.x,
                y = self.vars.y,
                r = self.vars.r,
                limit = self.limit,
                align = self.align,
                ox = self.ox,
                oy = self.oy,
                sx = self.sx,
                sy = self.sy,
                kx = self.kx,
                ky = self.ky,
                color = self.color,
            })
        end
    end

return Print