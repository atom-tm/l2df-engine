local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"
local Event = core.import "core.manager.event"

local Frames = Component:extend({ unique = true })

    function Frames:init()
        self.entity = nil
    end

    function Frames:added(entity, vars, starting, frameList)
        if not entity then return false end
        self.entity = entity
        starting = starting or 1
        frameList = frameList or { }

        self.frame = nil
        self.wait = 0
        self.next = starting
        self.counter = 0

        self.list = { }
        for i = 1, #frameList do
            self:add(frameList[i])
        end

        Event:subscribe("update", self.update, nil, self)
    end

    function Frames:add(frame)
        if not frame.id then return end
        self.list[frame.id] = frame
    end

    function Frames:set(n, sw)
        local nFrame = self.list[n] or self.list[next(self.list)]
        if not nFrame then return end
        self.frame = nFrame
        self.next = nFrame.next
        self.wait = nFrame.wait
        self.counter = sw or 0
    end

    function Frames:update(dt)
        if self.counter >= self.wait then
            self.counter = self.counter - self.wait
            self:set(self.next, self.counter)
        end
        if not self.frame then return end
        for k, v in pairs(self.frame) do
            self.entity.vars[k] = v
        end
        self.counter = self.wait > 0 and self.counter + dt * 1000 or 0
    end

return Frames