local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Core.Entities works only with l2df v1.0 and higher")

local Object = core.import "core.object"
local System = core.import "core.entities.system"

local next = _G.next
local type = _G.type
local pairs = _G.pairs
local ipairs = _G.ipairs
local rawset = _G.rawset
local table_remove = table.remove

--- Determine if object is array or not
-- TODO: it's pretty fast, but error prone
-- @return bool
local function isArray(obj)
	return type(obj) == "table" and (obj[1] ~= nil or next(obj) == nil)
end

--- Check if object matches filter
-- @return bool
local function matchesFilter(object, filter)
	if type(filter) == "function" then
		return filter(object) and true or false
	elseif type(filter) == "table" then
		if isArray(filter) then
			for i = 1, #filter do
				if not matchesFilter(object, filter[i]) then
					return false
				end
			end
		elseif filter.isTypeOf then
			return object:isInstanceOf(filter)
		else
			for key, value in pairs(filter) do
				if object[key] ~= value then
					return false
				end
			end
		end
		return true
	end
	return object[filter] ~= nil
end


local EntityManager = Object:extend()

	--- Entity manager constructor
	-- @param options, table  Optional parameters: groups, systems
	function EntityManager:init(options)
		options = options or { }
		self.entities = { }
		self.groups = { }
		self.context = { }
		self.has_entity = { }
		self.___systems = { }
		self.___events = { }

		local groups = options.groups or { }
		for key, filter in pairs(groups) do
			self.groups[key] = {
				name = key,
				filter = filter,
				entities = { },
				has_entity = { },
			}
		end

		local systems = options.systems or { }
		for _, system in ipairs(systems) do
			self:addSystem(system)
		end
	end

	---
	-- @param entity, Entity
	-- @return bool
	function EntityManager:hasEntity(entity)
		return self.has_entity[entity] and true or false
	end

	--- Add new entities to manager
	-- @param entities, Entity|array
	function EntityManager:add(entities)
		-- assert(entity:isInstanceOf(Entity), "not a subclass of Entities.Entity")d
		if not isArray(entities) then
			entities = { entities }
		end

		local entity
		for i = 1, #entities do
			entity = entities[i]
			rawset(self.entities, #self.entities + 1, entity)

			entity.___groups = { }
			local size = 1
			for name, group in pairs(self.groups) do
				if not group.has_entity[entity] and matchesFilter(entity, group.filter) then
					rawset(group.entities, #group.entities + 1, entity)
					rawset(entity.___groups, size, name)
					size = size + 1
					self:emit("addedtogroup", group, entity)
				end
			end
			self:emit("entityadded", entity)
		end
	end

	---
	-- @param ctx, table
	function EntityManager:setContext(ctx)
		local context = self.context[ctx]
		if not context then
			context = { entities = { }, groups = { }, has_entity = { } }
			for name, group in pairs(self.groups) do
				context.groups[name] = {
					name = group.name,
					filter = group.filter,
					entities = { },
					has_entity = { }
				}
			end
		end
		self.groups = context.groups
		self.entities = context.entities
		self.has_entity = context.has_entity

		for i = 1, #self.___systems do
			self.___systems[i].manager = self
			self.___systems[i].groups = self.groups
		end

		self.context[ctx] = context
	end

	--- Remove entity from manager by id
	-- @param id, number
	function EntityManager:removeById(id)
		local entity = table_remove(self.entities, id)
		self.has_entity[entity] = nil

		local groups = entity.___groups
		if not isArray(groups) then
			groups = { }
			local size = 1
			for name, group in pairs(self.groups) do
				if group.has_entity[entity] then
					rawset(groups, size, name)
					size = size + 1
				end
			end
		end

		local group
		for i = 1, #groups do
			group = self.groups[groups[i]]
			for j = #group.entities, 1, -1 do
				if group.entities[j] == entity then
					table_remove(group.entities, j)
					self:emit("removedfromgroup", group, entity)
					break
				end
			end
		end
		self:emit("entityremoved", entity)
	end

	--- Remove entity from manager by filter
	-- @param filter, function|table|string
	function EntityManager:removeByFilter(filter)
		for i = #self.entities, 1, -1 do
			if matchesFilter(self.entities[i], filter) then
				self:removeById(i)
			end
		end
	end

	--- Remove entity from manager
	-- @param entity, Entity
	function EntityManager:remove(entity)
		for i = #self.entities, 1, -1 do
			if self.entities[i] == entity then
				self:removeById(i)
				break
			end
		end
	end

	--- Trigger event for systems and entitiess
	-- @param event, string  Event name
	-- @params
	function EntityManager:emit(event, ...)
		local system
		for i = 1, #self.___systems do
			system = self.___systems[i]
			if type(system[event]) == 'function' then
				system[event](system, ...)
			end
		end

		local events = self.___events[event]
		if events then
			for i = 1, #events do
				events[i](...)
			end
		end
	end

	---
	-- @param event, string
	-- @param listener, function
	-- @return function
	function EntityManager:on(event, listener)
		local listeners = self.___events[event] or { }
		rawset(listeners, #listeners + 1, listener)
		rawset(self.___events, event, listeners)
		return listener
	end

	---
	-- @param event, string
	-- @param listener, function
	-- @return self
	function EntityManager:off(event, listener)
		local listeners = self.___events[event]
		if not listeners then return end

		for i = #listeners, 1, -1 do
			if listeners[i] == listener then
				table_remove(listeners, i)
			end
		end
		return self
	end

	--- Attach system to manager
	-- @param system, System
	function EntityManager:addSystem(system)
		-- assert(system:isInstanceOf(System), "not a subclass of Entities.System")
		system.manager = self
		system.groups = self.groups
		rawset(self.___systems, #self.___systems + 1, system)
	end

	--- Remove system from manager by its type
	-- @param def, System
	function EntityManager:removeSystemByType(def)
		-- assert(def:isInstanceOf(System), "not a subclass of Entities.System")
		for i = #self.___systems, 1, -1 do
			if self.___systems[i]:isTypeOf(def) then
				table_remove(self.___systems, i)
			end
		end
	end

	--- Get system from manager by its type
	-- @param def, System
	function EntityManager:getSystemByType(def)
		-- assert(def:isInstanceOf(System), "not a subclass of Entities.System")
		for i = 1, #self.___systems do
			if self.___systems[i]:isTypeOf(def) then
				return self.___systems[i]
			end
		end
	end

return EntityManager