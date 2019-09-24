local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"

local Event = core.import "core.manager.event"
local RenderManager = core.import "core.manager.render"
local ResourseManager = core.import "core.manager.resourse"

local Print = Component:extend({ unique = false })

    function Print:init(text)
        self.entity = nil
        self.text = text
    end

    function Print:added(entity, vars, sprites)
        if not entity then return false end
        self.entity = entity
        self.vars = vars

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0
        vars.scalex = vars.scalex or 1
        vars.scaley = vars.scaley or 1
        vars.hidden = vars.hidden or false

        Event:subscribe("update", self.update, nil, self)
    end

    function Print:setText(text)
        self.text = text
    end


    function Print:update()
        if not self.hidden then
            RenderManager:add({ self.text }, self.vars.x, self.vars.y)
        end
    end

return Print