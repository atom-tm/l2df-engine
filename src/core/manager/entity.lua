local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "EntityManager works only with l2df v1.0 and higher")

local Entity = core.import "core.class.entity"
local Storage = core.import "core.class.storage"

local Manager = { root = nil, list = Storage:new() }

	function Manager:setRoot(entity)
		assert(entity and entity:isInstanceOf(Entity), "To use the Entity Manager, you must specify the root entity")
		self.root = entity
	end

	function Manager:enum(beginer, options)
		assert(beginer and beginer:isInstanceOf(Entity), "Entity Manager works only with representatives of the Entity class")
		local root
		if options and options.childsOnly then
			root = { beginer and beginer:getNodes(), 0, #beginer:getNodes() }
		else
			root = { { beginer }, 0, 1 }
		end
		local list = { root }
		local depth = 1
		local i = 0
		local current = list[depth]
		return function ()
			if i < current[3] or depth > 1 then
				i = i + 1
				local returned = current[1][i]
				local nodes = current[1][i] and current[1][i]:getNodes()
				if nodes and next(nodes) then
					current[2] = i
					depth = depth + 1
					list[depth] = { nodes, 0, #nodes }
					current = list[depth]
					i = 0
				elseif i >= current[3] and depth > 1 then
					depth = depth - 1
					current = list[depth]
					i = current[2]
				end
				print("i: " .. i)
				print("depth: " .. depth)
				print("current: " .. tostring(current))
				print("nodes: " .. #nodes)
				print("--------------")
				return returned
			else return nil end
		end
	end

	--- Add new entity to manager
	--  @param entity, Entity
	function Manager:add(entity)
		assert(entity and entity:isInstanceOf(Entity), "Entity Manager works only with representatives of the Entity class")
		local id = self.list:add(entity)
		entity.id = id
		return id
	end


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


	--- showList test function
	function Manager:showList()
		for id, element in self.list:enum() do
			print("[" .. id .. "] " .. tostring(element))
		end
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