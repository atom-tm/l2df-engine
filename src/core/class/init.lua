local core = l2df or require((...):match('(.-)[^%.]+$'))
assert(type(core) == 'table' and core.version >= 1.0, 'Classes works only with l2df v1.0 and higher')

local Class = { }

	--- David blaine's fucking street magic
	function Class:___getInstance()
		local obj = setmetatable({
				___class = self
			}, self)
		self.__index = self
		self.__call = function (cls, ...) return cls:new(...) end
		return obj
	end

	--- Inheritance
	function Class:extend(...)
		local cls = self:___getInstance()
		cls.super = setmetatable({ }, {
				__index = self,
				__call = function (_, child, ...)
					return self.init(child, ...)
				end
			})
		for _, param in pairs{...} do
			if type(param) == 'function' then
				param(cls, self)
			elseif type(param) == 'table' then
				for k, v in pairs(param) do
					cls[k] = v
				end
			end
		end
		return cls
	end

	--- Creating a class instance
	function Class:new(...)
		local obj = self:___getInstance()
		obj:init(...)
		return obj
	end

	--- Class initialization
	function Class:init(int)
		self.x = int
		-- pass
	end

	---
	function Class.isTypeOf(obj, cls)
		return obj and (obj.___class == cls)
	end

	---
	function Class.isInstanceOf(obj, cls)
		return obj and (obj.___class == cls or Class.isInstanceOf(obj.___class, cls))
	end

return Class