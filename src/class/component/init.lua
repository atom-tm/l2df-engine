--- Component class
-- @classmod l2df.class.component
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require((...):match('(.-)class.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Class = core.import 'class'

local Component = Class:extend()

	--- Get entity's variables proxy table
	-- @param l2df.class.entity obj
	-- @return table
	function Component:data(obj)
		if type(obj) ~= 'table' then return nil end
		local meta = obj.___meta
		if meta and obj.data and not meta[self] then
			obj.data[self] = obj.data[self] or { }
			meta[self] = setmetatable({ }, {
				__index = function (_, key)
					return obj.data[self][key] or obj.data[key]
				end,
				__newindex = function (_, key, value)
					obj.data[self][key] = value
				end
			})
		end
		return meta and meta[self]
	end

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

	--- Component added to l2df.class.entity
	-- @param l2df.class.entity obj
	function Component:added(obj)
		--
	end

	--- Component removed from l2df.class.entity
	-- @param l2df.class.entity obj
	function Component:removed(obj)
		obj.data[self] = nil
		if obj.___meta then
			obj.___meta[self] = nil
		end
	end

return Component