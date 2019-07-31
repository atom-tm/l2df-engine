local Object = { }

	function Object:___getInstance()
		local obj = setmetatable({
				___class = self
			}, self)
		self.__index = self
		self.__call = function (cls, ...) return cls:new(...) end
		return obj
	end

	function Object:extend(...)
		local cls = self:___getInstance()
		cls.super = setmetatable({ }, {
				__index = self,
				__call = function (_, child, ...)
					return self.init(child, ...)
				end
			})
		for _, param in pairs{...} do
			if type(param) == "function" then
				param(cls, self)
			elseif type(param) == "table" then
				for k, v in pairs(param) do
					cls[k] = v
				end
			end
		end
		return cls
	end

	function Object:new(...)
		local obj = self:___getInstance()
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
