local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"

local Event = core.import "core.manager.event"
local Render = core.import "core.manager.render"

local Draw = Component:extend({ unique = true })

    function Draw:init()
        self.entity = nil
    end

    function Draw:added(entity, resourse)
        if not entity then return false end
        self.entity = entity

        entity.x = entity.x or 0
        entity.y = entity.y or 0
        entity.r = entity.r or 0

        entity.scalex = entity.scalex or 1
        entity.scaley = entity.scaley or 1

        entity.hidden = entity.hidden or 0
        entity.pic = entity.pic or 0

        self.resourse = love.graphics.newImage(resourse)
        Event:subscribe("update", self.update, nil, self)
    end

    function Draw:update()
        local _ = not self.hidden and Render:add(self.resourse, self.entity.x, self.entity.y)
    end

return Draw