--- States component
-- @classmod l2df.class.component.states
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local tostring = _G.tostring

local Component = core.import 'class.component'
local StatesManager = core.import 'manager.states'

local States = Component:extend({ unique = true })

    function States:init()
        self.entity = nil
    end

    function States:added(entity)
        if not entity then return false end

        self.entity = entity
        local vars = entity.vars
        vars.persistentStates = vars.persistentStates or { }
        vars.states = vars.states or { }
    end

    function States:update(dt)
        if not self.entity then return end

        local vars = self.entity.vars
    	for i = 1, #vars.persistentStates do
    		StatesManager:get(tostring(vars.persistentStates[i][1])):persistentUpdate(vars, vars.persistentStates[i][2])
    	end
    	for i = 1, #vars.states do
    		StatesManager:get(tostring(vars.states[i][1])):update(vars, vars.states[i][2])
    	end
    	vars.states = { }
    end

return States