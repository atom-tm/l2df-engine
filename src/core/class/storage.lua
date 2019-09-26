local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local Class = core.import "core.class"

local Storage = Class:extend()

	--- Storage initialization
	function Storage:init()
		self.list = {}
		self.map = {}
		self.free = {}
		self.length = 0
	end

	--- Add new object to storage
	--  @param object
	function Storage:add(object, reload)
		local id = self:has(object)
		if id and not reload then return id end

		if #self.free > 0 then
			id = self.free[#self.free]
			self.free[#self.free] = nil
		else
			self.length = self.length + 1
			id = self.length
		end

		self.list[id] = object
		self.map[object] = id
		return id, object
	end

	function Storage:addById(object, id, reload)
		local obj = self:getById(id)
		if obj and not reload then return obj, id end

		self.list[id] = object
		self.map[object] = id

		return id, object
	end


	--- Remove object from storage
	--  @param object
	function Storage:remove(object)
		local id = self.map[object]
		if not id then return false end
		self.list[id] = nil
		self.map[object] = nil
		self.free[#self.free + 1] = id
		self.length = id == self.length and self.length - 1 or self.length
		return true
	end

	--- Remove object from storage by Id
	--  @param id, number
	function Storage:removeById(id)
		if not self.list[id] then return false end
		self.map[self.list[id]] = nil
		self.list[id] = nil
		self.free[#self.free + 1] = id
		return true
	end

	--- Return object from storage by Id
	function Storage:getById(id)
		return self.list[id] or false
	end

	--- Checks for object in storage
	function Storage:has(object)
		return self.map[object] or false
	end

	function Storage:enum(skipNil)
		local id = 0
		return function ()
			while id < self.length do
				id = id + 1
				if not skipNil or self.list[id] ~= nil then
					return id, self.list[id]
				end
			end
			return nil
		end
	end

	function Storage:pairs(skipNil)
		local index, object
		return function ()
			index, object = next(self.list, index)
			if not skipNil or object ~= nil then
				return index, object
			end
		end
	end

return Storage