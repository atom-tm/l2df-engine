--- Component class. Inherited from @{l2df.class|l2df.Class}.
-- @classmod l2df.class.component
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require((...):match('(.-)class.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local assert = _G.assert
local type = _G.type
local setmetatable = _G.setmetatable

local Class = core.import 'class'

local Component = Class:extend()

	--- Get entity's variables proxy table.
	-- Used for encapsulation of component's variables inside @{l2df.class.entity.data|Entity.data}.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @return table
	function Component:data(obj)
		if type(obj) ~= 'table' then return nil end
		local cname = self-- [1]
		-- assert(type(cname) == 'string', 'to store component data inside entity you must define its unique name')
		local meta = obj.___meta
		if meta and obj.cdata and not meta[self] then
			obj.cdata[cname] = obj.cdata[cname] or { }
			meta[self] = setmetatable({ }, {
				__index = function (_, key)
					return obj.cdata[cname][key] or obj.data[key]
				end,
				__newindex = function (_, key, value)
					obj.cdata[cname][key] = value
				end
			})
		end
		return meta and meta[self]
	end

	--- Wrap component with @{l2df.class.entity|entity} together.
	-- Returns proxy table which gives you access to all component's functions without need to pass entity's instance.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @return l2df.class.component
	function Component:wrap(obj)
		self.wrappers = self.wrappers or { } --setmetatable({ }, { __mode = 'k' })
		self.wrappers[obj] = self.wrappers[obj] or { }
		return setmetatable({ }, {
			__index = function (t, k)
				if k == 'object' then
					return obj
				elseif self.wrappers[obj][k] then
					return self.wrappers[obj][k]
				elseif type(self[k]) == 'function' then
					local wrap = function (...) return self[k](self, obj, ...) end
					self.wrappers[obj][k] = wrap
					return wrap
				end
				return self[k]
			end,
			__call = function ()
				return self
			end
		})
	end

	--- Component was added to @{l2df.class.entity|Entity} event.
	-- @param l2df.class.entity obj  Entity's instance.
	function Component:added(obj)
		--
	end

	--- Component was removed from @{l2df.class.entity|Entity} event.
	-- @param l2df.class.entity obj  Entity's instance.
	function Component:removed(obj)
		obj.cdata[self] = nil --[1] or 1
		if obj.___meta then
			obj.___meta[self] = nil
		end
	end

return Component