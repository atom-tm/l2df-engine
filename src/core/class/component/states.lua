local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"
local StatesManager = core.import "core.manager.states"
local EventManager = core.import "core.manager.event"

local States = Component:extend({ unique = true })

    function States:init()
        self.entity = nil
        self.vars = nil
    end

    function States:added(entity, vars)
        if not entity then return false end
        self.entity = entity
        self.vars = vars

        vars.persistentStates = vars.persistentStates or { }
        vars.states = vars.states or { }
    end

    function States:update()
        if not self.entity.active then return end
    	for i = 1, #self.vars.persistentStates do
    		StatesManager:get(tostring(self.vars.persistentStates[i][1])):persistentUpdate(self.vars, self.vars.persistentStates[i][2])
    	end
    	for i = 1, #self.vars.states do
    		StatesManager:get(tostring(self.vars.states[i][1])):update(self.vars, self.vars.states[i][2])
    	end
    	self.vars.states = { }
    end

return States