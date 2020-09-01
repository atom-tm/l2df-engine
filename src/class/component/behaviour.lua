--- Behaviour component
-- @classmod l2df.class.component.behaviour
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Storage = core.import 'class.storage'
local Component = core.import 'class.component'

local tostring = _G.tostring

local Behaviour = Component:extend({ unique = true })

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
			data.head = 1
		end

		data.params = data.params or { }
		data.behave = data.behave or { }
		data.head = data.head or 0
		data.list = data.list or { }
	end

	function Behaviour:invoke(obj, method, ...)
		local data = self:data(obj)
		if data.head < 1 then return end
		local behave = data.behave[data.head]
		for id, obj in behave:enum() do
			if type(obj[method]) == 'function' then
				obj[method](obj, ...)
			end
		end
	end

	function Behaviour:append(obj, item, params)
		if type(obj) ~= 'table' then
			return false
		end
		local data = self:data(obj)
		local id = data.behave[data.head]:add(item)
		data.params[data.head][id] = params
		return true
	end

	function Behaviour:remove(obj, item)
		if type(item) ~= 'table' then
			return false
		end
		local data = self:data(obj)
		local id = data.behave[data.head]:remove(item)
		if id then data.params[data.head][id] = nil end
		return true
	end

	function Behaviour:clear(obj, till)
		till = till or 0
		local data = self:data(obj)
		local behave = data.behave
		local params = data.params
		for i = data.head, till + 1, -1 do
			behave[i] = nil
			params[i] = nil
		end
		data.head = till
		return true
	end

	function Behaviour:has(obj, item)
		local data = self:data(obj)
		local behave = data.behave[data.head]
		return behave and behave:has(item) or false
	end

	function Behaviour:switch(obj, item, params)
		if type(item) ~= 'table' or not self:clear(obj, 1) then
			return false
		end
		local data = self:data(obj)
		local behave = data.behave
		behave[1] = Storage:new()
		local id = behave[1]:add(item)
		data.params[1] = { [id] = params }
		return true
	end

	function Behaviour:push(obj, item, params)
		if type(item) ~= 'table' then
			return false
		end
		local data = self:data(obj)
		data.head = data.head + 1
		local behave = Storage:new()
		local id = behave:add(item)
		data.behave[data.head] = behave
		data.params[data.head] = { [id] = params }
		return true
	end

	function Behaviour:pop(obj)
		local data = self:data(obj)
		if data.head > 0 then
			data.behave[data.head] = nil
			data.params[data.head] = nil
			data.head = data.head - 1
		end
	end

	function Behaviour:preupdate(obj, dt)
		local data = self:data(obj)
		if data.head > 0 then
			self:invoke(obj, 'preupdate', dt, data.params[data.head])
		end
	end

	function Behaviour:update(obj, dt)
		local data = self:data(obj)
		if data.head > 0 then
			self:invoke(obj, 'update', dt, data.params[data.head])
		end
	end

	function Behaviour:postupdate(obj, dt)
		local data = self:data(obj)
		if data.head > 0 then
			self:invoke(obj, 'postupdate', dt, data.params[data.head])
		end
	end

return Behaviour