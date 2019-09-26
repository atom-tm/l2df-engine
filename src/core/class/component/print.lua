local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"

local Event = core.import "core.manager.event"
local RenderManager = core.import "core.manager.render"
local ResourseManager = core.import "core.manager.resourse"

local Print = Component:extend({ unique = false })

    function Print:init(text, font, options)
        self.entity = nil
        self:set(text, font, options)
    end

    function Print:set(text, font, options)
        font = font and font.typeOf and font:typeOf('Font') and font or nil
        options = options or { }
        self.text = text or self.text or ''
        self.font =  font or self.font or love.graphics.newFont()
        self.limit = options.limit or self.font:getWidth(text)
        self.align = options.align or self.align or 'left'
        self.ox = options.ox or self.ox or 0
        self.oy = options.oy or self.oy or 0
        self.kx = options.kx or self.kx or 0
        self.ky = options.ky or self.ky or 0
        self.sx = options.sx or self.sx or 1
        self.sy = options.sy or self.sy or 1
        self.color = options.color and { (options.color[1] or 255) / 255, (options.color[2] or 255) / 255, (options.color[3] or 255) / 255, (options.color[4] or 255) / 255 } or { 1,1,1,1 }
    end

    function Print:added(entity, vars, sprites)
        if not entity then return false end
        self.entity = entity
        self.vars = vars

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0
        vars.hidden = vars.hidden or false

        Event.subscribe(entity, 'update', self.update, nil, self)
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