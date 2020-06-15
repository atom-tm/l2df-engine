--- States component
-- @classmod l2df.class.component.states
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local tostring = _G.tostring

local State = core.import 'class.state'
local Storage = core.import 'class.storage'
local Component = core.import 'class.component'
local helper = core.import 'helper'
--local StatesManager = core.import 'manager.states' -- работу менеджера временно перекладываю на компонент,
-- возможно для многих компонентов не потроебуются более менеджеры

local statesLocalStorage = {}

-- todo: перенести в менеджер
function Run( id, entity, data )
	if type(statesLocalStorage[id]) == "function" then
		statesLocalStorage[id](entity, data)
	end
end



local States = Component:extend({ unique = true })

	function States:init()
		self.entity = nil
	end

	function States:added(entity, kwargs, states)
		self.entity = entity
		local vars = entity.vars

		vars.states = vars.states or {  }
		vars.constates = vars.constates or kwargs.constates or {  }

		local states = states or { }

		for i = 1, #states do
            self:load(states[i])
        end

	end

	-- todo: перенести эту функцию в менеджер стейтов
	function States:load( func, id )
		local filename
		if type(func) == "string" then func, filename = helper.requireFile(func) end
		if type(func) ~= "function" then return end

		id = id or filename or #statesLocalStorage + 1
		statesLocalStorage[id] = func
	end



	function States:add(data, id, constate)
		local vars = self.entity.vars
		local storage = constate and vars.constates or vars.states
		data[1] = data[1] or id
		storage[#storage + 1] = data
		return #storage -- #ID
	end

	function States:remove(id, constate)
		local vars = self.entity.vars
		local storage = constate and vars.constates or vars.states
		if (not id) or id > #storage then return end
		table.remove(storage, id)
	end

	function States:clear(constates)
		local vars = self.entity.vars
		if constates then
			vars.constates = {  }
		else
			vars.states = {  }
		end
	end



	function States:update(dt)
		local vars = self.entity.vars

		for i = 1, #vars.states do
			Run(vars.states[i][1], self.entity, vars.states[i])
		end
		self:clear()

		for i = 1, #vars.constates do
			Run(vars.constates[i][1], self.entity, vars.constates[i])
		end
	end













	--[[function States:added(entity, kwargs)
		if not entity then return false end

		self.entity = entity
		local vars = entity.vars
		local states = kwargs and (kwargs.states or { kwargs.state }) or { }

		if #states > 0 then
			vars.persistent_states = Storage()
			vars.persistent_params = { {} }
			local id
			for i = 1, #states do
				id = vars.persistent_states[1]:add(states[i][1])
				vars.persistent_params[1][id] = states[i][2]
			end
			vars.states_head = 1
		else
			vars.persistent_params = vars.persistent_params or { }
			vars.persistent_states = vars.persistent_states or { }
			vars.states_head = vars.states_head or 0
		end

		vars.states = vars.states or { }
	end]]

	--[[function States:invoke(method, ...)
		if not self.entity then return end
		local vars = self.entity.vars
		local states = vars.persistent_states[vars.states_head]
		for id, state in states:enum() do
			if type(state[method]) == 'function' then
				state[method](state, ...)
			end
		end
	end]]

	--[[function States:append(state, params)
		if not self.entity or not state then return end
		local vars = self.entity.vars
		local id = vars.persistent_states[vars.states_head]:add(state)
		vars.persistent_params[vars.states_head][id] = params
	end]]

	--[[function States:remove(state)
		if not self.entity or not state then return end
		local vars = self.entity.vars
		local id = vars.persistent_states[vars.states_head]:remove(state)
		if id then vars.persistent_params[vars.states_head][id] = nil end
	end]]

	--[[function States:clear(till)
		till = till or 0
		if not self.entity then return false end
		local vars = self.entity.vars
		local states = vars.persistent_states
		local params = vars.persistent_params
		for i = vars.states_head, till + 1, -1 do
			states[i] = nil
			params[i] = nil
		end
		vars.states_head = till
		return true
	end]]

	--[[function States:has(state)
		if not self.entity then return false end
		local vars = self.entity.vars
		local state = vars.persistent_states[vars.states_head]
		return state and state:has(state) or false
	end]]

	--[[function States:switch(state, params)
		if not self:clear(1) or not state then return end
		local vars = self.entity.vars
		local states = vars.persistent_states
		states[1] = Storage()
		local id = states[1]:add(state)
		vars.persistent_params[1] = { [id] = params }
	end]]

	--[[function States:push(state, params)
		if not self.entity or not state then return end
		local vars = self.entity.vars
		vars.states_head = vars.states_head + 1
		local states = Storage()
		local id = states:add(state)
		vars.persistent_states[vars.states_head] = states
		vars.persistent_params[vars.states_head] = { [id] = params }
	end]]

	--[[function States:pop()
		if not self.entity then return end
		local vars = self.entity.vars
		if vars.states_head > 0 then
			vars.persistent_states[vars.states_head] = nil
			vars.persistent_params[vars.states_head] = nil
			vars.states_head = vars.states_head - 1
		end
	end]]

	--[[function States:update(dt)
		if not self.entity then return end

		local vars = self.entity.vars
		if vars.states_head > 0 then
			local states = vars.persistent_states[vars.states_head]
			local params = vars.persistent_params[vars.states_head]
			for i, state in states:enum() do
				if type(state) == 'table' then
					state:persistentUpdate(dt, self.entity, params[i])
				else
					StatesManager:get(tostring(state)):persistentUpdate(dt, self.entity, params[i])
				end
			end
		end
		for i = 1, #vars.states do
			StatesManager:get(tostring(vars.states[i][1])):update(self.entity, vars.states[i][2])
		end
		vars.states = { }
	end]]

return States
