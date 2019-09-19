local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "EntityManager works only with l2df v1.0 and higher")

local Entity = core.import "core.class.entity"
local Storage = core.import "core.class.storage"

local list = Storage:new()

local Manager = { root = nil, list = list }

	--- Setting an entity as a root node (to "tree" enum)
	function Manager:setRoot(entity)
		assert(entity and entity:isInstanceOf(Entity), "To use the Entity Manager, you must specify the root entity")
		self.root = entity
	end


	--- Brute force entities on the tree of heredity
	function Manager:enum(beginer, options)
		assert(beginer and beginer:isInstanceOf(Entity), "Entity Manager works only with representatives of the Entity class")
		options = type(options) == "table" and options or {}
		beginer = beginer and { beginer } or { self.root }
		if options.skipRoot then beginer = beginer[1]:getNodes() end
		local tasks = { { beginer, 0, #beginer } }
		local depth = 1
		local i = 0
		local current = tasks[depth]
		return function ()
			while i < current[3] or depth > 1 do
				i = i + 1
				local returned = current[1][i]
				local nodes = returned and returned:getNodes()
				if nodes and next(nodes) then
					current[2] = i
					current = { nodes, 0, #nodes }
					tasks[#tasks + 1] = current
					depth = depth + 1
					i = 0
				elseif i >= current[3] and depth > 1 then
					depth = depth - 1
					current = tasks[depth]
					i = current[2]
				end
				return returned
			end
			return nil
		end
	end


	--- Add new entity to manager
	--  @param entity, Entity
	function Manager:add(entity)
		assert(entity and entity:isInstanceOf(Entity), "Entity Manager works only with representatives of the Entity class")
		local id = self.list:add(entity)
		entity.id = id
		return id, entity
	end


	--- Create new entity and add to manager
	-- @param class, Class
	function Manager:create(class, ...)
		return Manager:add(class:new(...))
	end


	--- Remove entity from manager
	--  @param entity, Entity
	function Manager:remove(entity)
		return self.list:remove(entity)
	end


	--- Remove entity from manager by Id
	--  @param id, number
	function Manager:removeById(id)
		return self.list:removeById(id)
	end


	--- Add new entities to manager
	--  @param entities, array
	function Manager:addMulti(entities)
		assert(type(entities) == "table", "The input is not a table")
		local list = {}
		for i = 1, #entities do
			list[#list] = self:add(entities[i])
		end
		return list
	end


	--- Checks for entity in storage
	function Manager:has(entity)
		return self.list:has(entity) or false
	end


	--- Return entity from storage by Id
	function Manager:getById(id)
		return self.list:getById(id) or false
	end


return Manager