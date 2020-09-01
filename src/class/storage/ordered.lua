--- OrderedStorage class
-- @classmod l2df.class.storage.ordered
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'OrderedStorage works only with l2df v1.0 and higher')

local rbtree = core.import 'external.rbtree'
local Storage = core.import 'class.storage'
local GSID = core.import 'manager.gsid'

local OrderedStorage = Storage:extend()

	--- OrderedStorage initialization
	function OrderedStorage:init()
		self:reset()
	end

	--- Reset storage flushing all stored data
	function OrderedStorage:reset()
		self.data = rbtree.new()
		self.keys = { }
		self.map = { }
		self.count = 0
	end

	--- Add new object to storage
	--  @param mixed object
	--  @param[opt] boolean reload
	-- @return number
	-- @return mixed
	function OrderedStorage:add(object, reload)
		local id = self.map[object]
		if id and not reload then return id, object end

		if not id then
			id = GSID:generate()
		end

		self.data[id] = object
		self.map[object] = id
		self.count = self.count + 1
		return id, object
	end

	--- Add object to storage with provided id
	-- @param mixed object
	-- @param number id
	-- @param boolean reload
	-- @return number
	-- @return mixed
	function OrderedStorage:addById(object, id, reload)
		local obj = self:getById(id)
		if obj and not reload then return id, obj
		elseif obj then self:remove(obj) end

		self.data[id] = object
		self.map[object] = id

		self.count = self.count + 1
		return id, object
	end

	--- Remove object from storage
	-- @param mixed object
	-- @return boolean
	function OrderedStorage:remove(object)
		local id = self.map[object]
		if not id then return false end
		self.data:remove(id)
		self.map[object] = nil
		return true
	end

	--- Remove object from storage by Id
	-- @param number id
	-- @return boolean
	function OrderedStorage:removeById(id)
		if not self.data[id] then return false end
		self.map[self.data[id]] = nil
		self.data:remove(id)
		return true
	end

	--- Enumerate storage data #1
	-- @return function
	function OrderedStorage:enum()
		return self.data:iter()
	end

	--- Enumerate storage data #2
	-- @return function
	function OrderedStorage:pairs()
		return self.data:iter()
	end

	--- Get first stored element
	-- @return mixed
	function OrderedStorage:first()
		return self.data:minimum()
	end

	--- Get last stored element
	-- @return mixed
	function OrderedStorage:last()
		return self.data:maximum()
	end

return OrderedStorage