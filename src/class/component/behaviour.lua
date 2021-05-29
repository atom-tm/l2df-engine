--- Behaviour component. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.behaviour
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Storage = core.import 'class.storage'
local Component = core.import 'class.component'

local tostring = _G.tostring

local Behaviour = Component:extend({ unique = true })

	--- Current stack size. To access use @{l2df.class.component.data|Behaviour:data()} function.
	-- @field number Behaviour.data.size

	--- Component was added to @{l2df.class.entity|Entity} event.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param[opt] {function,...} kwargs  Keyword arguments. Contains function for creating single-function behaviours.
	-- @param[opt] table kwargs.behaviours  List of initial behaviours to add.
	function Behaviour:added(obj, kwargs)
		if not obj then return false end

		local tkw = type(kwargs)
		local data = self:data(obj)
		local list = tkw == 'table' and kwargs.behaviours or { }

		if tkw == 'function' then
			list[#list + 1] = {{ update = kwargs }}
		elseif tkw == 'table' then
			for i = 1, #kwargs do
				if type(kwargs[i]) == 'function' then
					list[#list + 1] = {{ update = kwargs[i] }}
				end
			end
		end

		if #list > 0 then
			data.behave = data.behave or { Storage:new() }
			data.params = data.params or { {} }
			local id
			for i = 1, #list do
				id = data.behave[1]:add(list[i][1])
				data.params[1][id] = list[i][2]
			end
			data.size = 1
		end

		data.params = data.params or { }
		data.behave = data.behave or { }
		data.size = data.size or 0
		data.list = data.list or { }
	end

	--- Search and invoke method on all currently subscribed objects.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param string method  Name of the Entity's method to invoke.
	-- @param ... ...  Arguments passed to calling method.
	function Behaviour:invoke(obj, method, ...)
		local data = self:data(obj)
		if data.size < 1 then return end
		local behave = data.behave[data.size]
		for id, obj in behave:enum() do
			if type(obj[method]) == 'function' then
				obj[method](obj, ...)
			end
		end
	end

	--- Subscribe object @{l2df.class.component.behaviour.update|update} event.
	-- Calls `item:enable()` function if available.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param table item  Object to subscribe.
	-- @param[opt] table params  Arguments array to pass during update.
	-- @return boolean
	function Behaviour:append(obj, item, params)
		if type(obj) ~= 'table' then
			return false
		end
		local data = self:data(obj)
		local id = data.behave[data.size]:add(item)
		local _ = item.enable and item:enable()
		data.params[data.size][id] = params
		return true
	end

	--- Unsubscribe object from @{l2df.class.component.behaviour.update|update} event.
	-- Calls `item:disable()` function if available.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param table item  Object to unsubscribe.
	-- @return boolean
	function Behaviour:remove(obj, item)
		if type(item) ~= 'table' then
			return false
		end
		local data = self:data(obj)
		local id = data.behave[data.size]:remove(item)
		if id then
			local _ = item.disable and item:disable()
			data.params[data.size][id] = nil
		end
		return true
	end

	--- Unsubscribe all appended objects.
	-- Calls `:enable()` function for each unsubscribed object where applicable.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param[opt=0] number depth  Depth of the stack deletion. Clears everything when set to 0.
	-- @return boolean
	function Behaviour:clear(obj, depth)
		depth = depth or 0
		local data = self:data(obj)
		local behave = data.behave
		local params = data.params
		for i = data.size, depth + 1, -1 do
			for _, x in behave[i]:enum() do
				_ = x.disable and x:disable()
			end
			behave[i] = nil
			params[i] = nil
		end
		data.size = depth
		return true
	end

	--- Returns true if object currently subscribed to this behaviour.
	-- It will return false if object is subscribed but is located in stack (see @{l2df.class.component.behaviour.push|push}).
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param table item  Source object.
	-- @return boolean
	function Behaviour:has(obj, item)
		local data = self:data(obj)
		local behave = data.behave[data.size]
		return behave and behave:has(item) or false
	end

	--- Put all subscribed objects in stack meaning they won't watch update event and subscribe passed object.
	-- Calls `:disable()` function for each object put in stack.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param table item  Source object.
	-- @param[opt] table params  Arguments array to pass during update.
	-- @return boolean
	function Behaviour:push(obj, item, params)
		if type(item) ~= 'table' then
			return false
		end
		local data = self:data(obj)
		if data.size > 0 then
			for _, x in data.behave[data.size]:enum() do
				_ = x.disable and x:disable()
			end
		end
		data.size = data.size + 1
		local behave = Storage:new()
		local id = behave:add(item)
		local _ = item.enable and item:enable()
		data.behave[data.size] = behave
		data.params[data.size] = { [id] = params }
		return true
	end

	--- Unsubscribe all appended objects and restore objects previously stored in stack or do nothing.
	-- Calls `:enable()` function for each subscribed and `:disable()` for each unsubscribed object.
	-- @param l2df.class.entity obj  Entity's instance.
	function Behaviour:pop(obj)
		local data = self:data(obj)
		if data.size > 0 then
			for _, x in data.behave[data.size]:enum() do
				_ = x.disable and x:disable()
			end
			data.behave[data.size] = nil
			data.params[data.size] = nil
			data.size = data.size - 1
		end
		if data.size > 0 then
			for _, x in data.behave[data.size]:enum() do
				_ = x.enable and x:enable()
			end
		end
	end

	--- Unsubscribe all appended objects, clear stack and subscribe only passed object.
	-- Calls `:enable()` function for each subscribed and `:disable()` for each unsubscribed object.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param table item  Source object.
	-- @param[opt] table params  Arguments array to pass during update.
	-- @return boolean
	function Behaviour:switch(obj, item, params)
		if type(item) ~= 'table' or not self:clear(obj, 1) then
			return false
		end
		local data = self:data(obj)
		local behave = data.behave
		behave[1] = Storage:new()
		local id = behave[1]:add(item)
		local _ = item.enable and item:enable()
		data.params[1] = { [id] = params }
		return true
	end

	--- Pre-update event handler. Calls once per game tick before main update.
	-- @{l2df.class.component.behaviour.invoke|Invokes} "preupdate" event on all subscribed objects.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number dt  Delta-time since last game tick.
	function Behaviour:preupdate(obj, dt)
		local data = self:data(obj)
		if data.size > 0 then
			self:invoke(obj, 'preupdate', dt, data.params[data.size])
		end
	end

	--- Update event handler. Calls once per game tick during main update.
	-- @{l2df.class.component.behaviour.invoke|Invokes} "update" event on all subscribed objects.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number dt  Delta-time since last game tick.
	function Behaviour:update(obj, dt)
		local data = self:data(obj)
		if data.size > 0 then
			self:invoke(obj, 'update', dt, data.params[data.size])
		end
	end

	--- Post-update event handler. Calls once per game tick after main update.
	-- @{l2df.class.component.behaviour.invoke|Invokes} "postupdate" event on all subscribed objects.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number dt  Delta-time since last game tick.
	function Behaviour:postupdate(obj, dt)
		local data = self:data(obj)
		if data.size > 0 then
			self:invoke(obj, 'postupdate', dt, data.params[data.size])
		end
	end

return Behaviour