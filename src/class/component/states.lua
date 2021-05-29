--- States component. Inherited from @{l2df.class.component|l2df.class.Component} class.
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

	--- State description table.
	-- @field ... ...  There're may be any amount of the &lt;key:value&gt; pairs.
	-- All of them can be accessed from the 3rd table argument passed to the state's function.
	-- For more info see @{l2df.manager.states.run|StatesManager:run()}.
	-- @table .State

	--- Constant state description table.
	-- Currently it is absolutely similar with @{l2df.class.component.states.State|State}.
	-- @field ... ...  There're may be any amount of the &lt;key:value&gt; pairs.
	-- All of them can be accessed from the 3rd table argument passed to the state's function.
	-- For more info see @{l2df.manager.states.run|StatesManager:run()}.
	-- @table .ConstantState

    --- Component was added to @{l2df.class.entity|Entity} event.
    -- Adds `"states"` key to the @{l2df.class.entity.C|Entity.C} table.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @param[opt] table kwargs  Keyword arguments.
    -- @param[opt] {l2df.class.component.states.ConstantState,...} kwargs.constates  Array of constant states
    -- which will be processed at each @{l2df.class.component.states.update|States:update()} event.
	function States:added(obj, kwargs)
		if not obj then return false end
		local data = obj.data
		kwargs = kwargs or { }
		obj.C.states = self:wrap(obj)
		data.states = data.states or { }
		data.constates = data.constates or kwargs.constates or { }
	end

    --- Component was removed from @{l2df.class.entity|Entity} event.
    -- Removes `"states"` key from @{l2df.class.entity.C|Entity.C} table.
    -- @param l2df.class.entity obj  Entity's instance.
    function States:removed(obj)
        self.super.removed(self, obj)
        obj.C.states = nil
    end

    --- Add new state to the collection.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @param l2df.class.component.states.State|l2df.class.component.states.ConstantState state  State description table.
    -- @param number|string id  ID of the state to be added. Used for calling @{l2df.manager.states.run|StatesManager:run()} function.
    -- Also ID could be provided as `state[1]` (first array index in the state variable).
    -- This ID couldn't be used in @{l2df.class.component.states.remove|States:remove()}, use returned value instead.
    -- @param[opt=false] boolean use_constate  Set to `true ` to add state as @{l2df.class.component.states.ConstantState|constant state}.
    -- @return number  ID of the state added in a local storage.
	function States:add(obj, state, id, use_constate)
		local data = obj.data
		local storage = use_constate and data.constates or data.states
		state[1] = id or state[1]
		storage[#storage + 1] = state
		return #storage
	end

	--- Remove previously @{l2df.class.component.states.add|added} state by ID.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number id  ID of the state to remove.
	-- @param[opt=false] boolean use_constate  Set to `true ` if you are removing @{l2df.class.component.states.ConstantState|constant state}.
	function States:remove(obj, id, use_constate)
		local data = obj.data
		local storage = use_constate and data.constates or data.states
		if (not id) or id > #storage then return end
		tremove(storage, id)
	end

	--- Clears all added @{l2df.class.component.states.State|states} (or @{l2df.class.component.states.ConstantState|constant states}).
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param[opt=false] boolean use_constate  Set to `true ` to clear all constant states.
	function States:clear(obj, use_constate)
		local data = obj.data
		if use_constate then
			data.constates = { }
		else
			data.states = { }
		end
	end

    --- Component update event handler.
    -- Executes all added @{l2df.class.component.states.State|states} and @{l2df.class.component.states.ConstantState|constant states}.
    -- All added states are removed after processing (except for constant states, they can be removed manually only).
    -- @param l2df.class.entity obj  Entity's instance.
	-- @param number dt  Delta-time since last game tick.
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