local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"

local Event = core.import "core.manager.event"
local Render = core.import "core.manager.render"

local Draw = Component:extend({ unique = true })

    function Draw:init()
        self.entity = nil
        self.resourse = nil
        self.hidden = false
    end

    function Draw:added(entity, resourse)
        self.entity = entity
        self.resourse = love.graphics.newImage(resourse)
        Event:subscribe("update", self.update, nil, self)
    end

    function Draw:update()
        local _ = not self.hidden and Render:add(self.resourse, self.entity.x, self.entity.y)
    end

return Draw