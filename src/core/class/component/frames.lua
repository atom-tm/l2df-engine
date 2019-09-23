local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"
local Event = core.import "core.manager.event"

local Frames = Component:extend({ unique = true })

    function Frames:init()
        self.entity = nil
    end

    function Frames:added(entity, starting, frameList)
        if not entity then return false end
        starting = starting or 1
        frameList = frameList or { }

        self.counter = 0
        self.frame = 0

        self.list = { }
        for i = 1, #frameList do
            self:addFrame(i, frameList[i])
        end

        print(#self.list)

        self:set(starting)
        --Event:subscribe("update", self.update, nil, self)
    end

    function Frames:addFrame(num, frame)
        self.list[num] = frame
    end

    function Frames:set(num)
        num = num or 0
        if self.list[num] then
            self.frame = num
            self.counter = 0
            print("Set frame: " .. num)
        end
    end


    function Frames:update()
        for key, val in pairs(self.list[self.frame]) do
            print(key)
        end
    end

return Frames