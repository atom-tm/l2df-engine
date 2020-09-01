--- States component
-- @classmod l2df.class.component.states
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local type = _G.type
local tostring = _G.tostring
local tremove = table.remove

local helper = core.import 'helper'
local Storage = core.import 'class.storage'
local Component = core.import 'class.component'
local StatesManager = core.import 'manager.states'

local States = Component:extend({ unique = true })

	function States:added(obj, kwargs)
		if not obj then return false end
		local data = obj.data
		data.states = data.states or { }
		data.constates = data.constates or kwargs.constates or { }
	end

	function States:add(obj, state, id, use_constate)
		local data = obj.data
		local storage = use_constate and data.constates or data.states
		state[1] = id or state[1]
		storage[#storage + 1] = state
		return #storage -- #ID
	end

	function States:remove(obj, id, use_constate)
		local data = obj.data
		local storage = use_constate and data.constates or data.states
		if (not id) or id > #storage then return end
		tremove(storage, id)
	end

	function States:clear(obj, use_constate)
		local data = obj.data
		if use_constate then
			data.constates = { }
		else
			data.states = { }
		end
	end

	function States:update(obj, dt)
		local data = obj.data
		for i = 1, #data.states do
			StatesManager:run(data.states[i][1], obj, data, data.states[i])
		end
		self:clear(obj)
		for i = 1, #data.constates do
			StatesManager:run(data.constates[i][1], obj, data, data.constates[i])
		end
	end

return States