local Object = { }

	function Object:__getInstance()
		obj = setmetatable({
				___class = self
			}, self)
		self.__index = self
		self.__call = function (cls, ...) return cls:new(...) end
		return obj
	end

	function Object:extend(...)
		cls = self:__getInstance()
		for _, f in pairs{...} do
			f(cls, self)
		end
		return cls
	end

	function Object:new(...)
		obj = self:__getInstance()
		obj:init(...)
		return obj
	end

	function Object:init()
		-- pass
	end

	function Object.isTypeOf(obj, cls)
		return obj and (obj.___class == cls)
	end

	function Object.isInstanceOf(obj, cls)
		return obj and (obj.___class == cls or Object.isInstanceOf(obj.___class, cls))
	end

return Object
