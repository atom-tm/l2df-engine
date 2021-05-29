--- Basic class for OOP.
-- @classmod l2df.class
-- @author Abelidze
-- @copyright Atom-TM 2019

local core = l2df or require((...):match('(.-)[^%.]+$'))
assert(type(core) == 'table' and core.version >= 1.0, 'Classes works only with l2df v1.0 and higher')

local Class = { }

	--- Super-class metatable used for accessing parent class and calling its overloaded functions.
	-- @field l2df.class l2df.class.super

	-- David blaine's fucking street magic.
	function Class:___getInstance()
		local obj = setmetatable({
				___class = self
			}, self)
		self.__index = self
		self.__call = function (cls, ...) return cls:new(...) end
		return obj
	end

	--- Method performing class inheritance.
	-- @param ... ...  Params with callback functions and field-extending tables.
	-- @return l2df.class
	function Class:extend(...)
		local cls = self:___getInstance()
		cls.super = setmetatable({ }, {
				__index = self,
				__call = function (_, child, ...)
					local s = child.super
					child.super = self.super
					local r = self.init(child, ...)
					child.super = s
					return r
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

	--- Constructor for creating a class instance.
	-- @param ... ...  Arguments passed to @{l2df.class.init|Class:init()} function.
	-- @return l2df.class
	function Class:new(...)
		local obj = self:___getInstance()
		obj:init(...)
		return obj
	end

	--- Class initialization.
	function Class:init()
		-- pass
	end

	--- Returns true if object and class have the same type. False otherwise.
	-- @param l2df.class obj  Source object.
	-- @param l2df.class cls  Source class.
	-- @return boolean
	function Class.isTypeOf(obj, cls)
		return obj and (obj == cls or obj.___class == cls)
	end

	--- Returns true if the object is an instance of the class. False otherwise.
	-- @param l2df.class obj  Source object.
	-- @param l2df.class cls  Source class.
	-- @return boolean
	function Class.isInstanceOf(obj, cls)
		return obj and (obj == cls or obj.___class == cls or Class.isInstanceOf(obj.___class, cls))
	end

return Class