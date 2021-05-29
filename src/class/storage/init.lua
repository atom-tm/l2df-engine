--- Storage class. Inherited from @{l2df.class|l2df.Class}.
-- @classmod l2df.class.storage
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Storage works only with l2df v1.0 and higher')

local Class = core.import 'class'

local Storage = Class:extend()

	--- Storage initialization.
	function Storage:init()
		self:reset()
	end

	--- Reset storage flushing all stored data.
	function Storage:reset()
		self.data = { }
		self.keys = { }
		self.map = { }
		self.free = { }
		self.length = 0
		self.count = 0
	end

	--- Add new object to storage.
	--  @param mixed object
	--  @param[opt=false] boolean reload
	-- @return number
	-- @return mixed
	function Storage:add(object, reload)
		local id = self.map[object]
		if id and not reload then return id, object end

		if #self.free > 0 then
			id = self.free[#self.free]
			self.free[#self.free] = nil
		else
			self.length = self.length + 1
			id = self.length
		end

		self.data[id] = object
		self.map[object] = id
		self.count = self.count + 1
		return id, object
	end

	--- Add object to storage with provided id.
	-- @param mixed object
	-- @param number id
	-- @param[opt=false] boolean reload
	-- @return number
	-- @return mixed
	function Storage:addById(object, id, reload)
		local obj = self:getById(id)
		if obj and not reload then return id, obj
		elseif obj then self.map[obj] = nil end

		self.data[id] = object
		self.map[object] = id

		self.count = self.count + 1
		return id, object
	end

	--- Add object to storage with provided key.
	-- @param mixed object
	-- @param string key
	-- @param[opt=false] boolean reload
	-- @return number
	-- @return mixed
	function Storage:addByKey(object, key, reload)
		local obj, id = self:getByKey(key)
		if obj and not reload then return self.keys[key], obj
		elseif obj then self.map[obj] = nil end

		id, obj = self:add(object)
		self.keys[key] = id
		return id, obj
	end

	--- Remove object from storage.
	-- @param mixed object
	-- @return number
	function Storage:remove(object)
		local id = self.map[object]
		if not id then return false end
		self.data[id] = nil
		self.map[object] = nil
		self.count = self.count - 1
		if id == self.length then
			self.length = self.length - 1
		else
			self.free[#self.free + 1] = id
		end
		return id
	end

	--- Remove object from storage by ID.
	-- @param number id
	-- @return number
	function Storage:removeById(id)
		if not self.data[id] then return false end
		self.map[self.data[id]] = nil
		self.data[id] = nil
		self.count = self.count - 1
		if id == self.length then
			self.length = self.length - 1
		else
			self.free[#self.free + 1] = id
		end
		return id
	end

	--- Return object from storage by ID.
	-- @param number id
	-- @return mixed
	function Storage:getById(id)
		return self.data[id] or false
	end

	--- Return object from storage by key.
	-- @param string key
	-- @return mixed
	function Storage:getByKey(key)
		key = self.keys[key]
		return key and self.data[key] or false
	end

	--- Checks for object in storage.
	-- @param mixed object
	-- @return boolean
	function Storage:has(object)
		return self.map[object] or false
	end

	--- Enumerate storage data #1.
	-- @param[opt=false] boolean skipNil
	-- @return function
	function Storage:enum(skipNil)
		local id = 0
		return function ()
			while id < self.length do
				id = id + 1
				if not skipNil or self.data[id] ~= nil then
					return id, self.data[id]
				end
			end
			return nil
		end
	end

	--- Enumerate storage data #2.
	-- @param[opt=false] boolean skipNil
	-- @return function
	function Storage:pairs(skipNil)
		local index, object
		return function ()
			index, object = next(self.data, index)
			if not skipNil or object ~= nil then
				return index, object
			end
		end
	end

	--- Get first stored element.
	-- @return mixed
	function Storage:first()
		for i = 1, self.length do
			if self.data[i] then return self.data[i] end
		end
		return false
	end

	--- Get last stored element.
	-- @return mixed
	function Storage:last()
		return self.data[self.length] or false
	end

return Storage