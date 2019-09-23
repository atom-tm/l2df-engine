local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"
local Event = core.import "core.manager.event"

local Script = Component:extend({ unique = false })

    function Script:init(filepath)
        self.entity = nil
        self.vars = nil

    end

    function Script:added(entity, vars, starting, frameList)
        if not entity then return false end
        self.entity = entity


    end

return Script