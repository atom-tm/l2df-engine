--- Entity class
-- @classmod l2df.class.entity
-- @author Abelidze, Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local Class = core.import 'class'
local Component = core.import 'class.component'
local Storage = core.import 'class.storage'

local default = helper.notNil
local copyTable = helper.copyTable
local dummy = function () return nil end

local Entity = Class:extend()

	--- Creating a entity instance
	function Entity:new(kwargs, key, ...)
		local obj = self:___getInstance()
		obj.key = key
		obj.nodes = Storage:new()
		obj.components = Storage:new()
		obj.components.class = { }
		obj.parent = nil
		obj.active = default(kwargs.active, true)
		obj.data = { ___shallow = true }
		obj.___meta = { }
		obj.C = { }
		obj.R = setmetatable({ }, {
			__index = function (t, k)
				if obj[k] then
					return obj[k]
				end
				local x = obj.nodes:getByKey(k)
				return x and x.R or nil -- t.R
			end,
			__newindex = function (t, k, v)
				obj[k] = v
			end,
			__call = function ()
				return obj
			end
		})
		obj:init(kwargs, key, ...)
		return obj
	end

	--- Create copy of current object (with all attached nodes)
	function Entity:clone()
		local entity = self:___getInstance()
		entity.nodes = Storage:new()
		entity.components = Storage:new()
		entity.data = copyTable(self.data)
		for id, node in self.nodes:enum(true) do
			node = node:clone()
			node.id = id
			entity:attach(node)
		end
		for id, component in self.components:enum(true) do
			local c = component:new()
			c.entity = entity
			entity.data[c] = self.data[component]
			entity.components:add(c)
		end
		return entity
	end

	--- Adding an inheritor to an object
	function Entity:attach(entity)
		assert(entity:isInstanceOf(Entity), 'not a subclass of Entity')
		if entity.parent == self or self:isDescendant(entity) then return false end
		if entity.parent then entity.parent:detach(entity) end
		entity.parent = self
		if entity.key then
			return self.nodes:addByKey(entity, entity.key, true)
		elseif entity.id then
			return self.nodes:addById(entity, entity.id, true)
		end
		return self.nodes:add(entity)
	end

	--- Adding some inheritors to an object
	function Entity:attachMultiple(array)
		array = array or { }
		for i = 1, #array do
			if array[i]:isInstanceOf(Entity) then
				self:attach(array[i])
			end
		end
	end

	--- Removing an inheritor from object
	function Entity:detach(entity)
		assert(entity:isInstanceOf(Entity), 'not a subclass of Entity')
		self.nodes:remove(entity)
		entity.parent = nil
	end

	function Entity:detachAll()
		for id, node in self.nodes:enum(true) do
			self:detach(node)
		end
	end

	--- Removing object from inheritors list of his parent
	function Entity:detachParent()
		if self.parent then
			self.parent:detach(self)
		end
		return true
	end

	--- Destory object
	function Entity:destroy()
		self:clearComponents()
		self:detachParent()
	end

	--- Getting a list of object inheritors
	-- @param[opt] function filter
	function Entity:getNodes(filter)
		local list = { }
		for id, node in self.nodes:enum(true) do
			if not filter or filter(node) then
				list[#list + 1] = node
			end
		end
		return list
	end

	--- Option to obtain a parent using the function
	function Entity:getParent()
		return self.parent
	end

	--- Backup / restore entity
	function Entity:sync(state)
		if not state then
			return {
				active = self.active,
				parent = self.parent,
				data = copyTable(self.data)
			}
		end
		if state.parent then
			state.parent:attach(self)
		end
		copyTable(state, self)
	end

	--- Check for inheritance from an object
	function Entity:isDescendant(entity)
		local object = self
		while object do
			if object == entity then return true end
			object = object.parent
		end
		return false
	end

	---
	-- @param boolean active
	-- @param[opt=false] boolean propagate
	function Entity:setActive(active, propagate)
		if active == nil then active = not self.active end
		if not propagate then
			self.active = active
			return true
		end
		if self.parent and not (self.parent.active) and active then
			return false
		end
		for object in self:enum() do
			object.active = active
		end
		return true
	end

	--- Add component to entity
	-- @param Component component
	function Entity:addComponent(component, ...)
		assert(component:isInstanceOf(Component), 'not a subclass of Component')
		if self:hasComponent(component) then return false end
		-- if component.unique and self:hasComponentClass(component.___class) then return false end
		self.components.class[component.___class] = self.components.class[component.___class] and self.components.class[component.___class] + 1 or 1
		return self.components:add(component), component, component.added and component:added(self, ...)
	end

	--- Create new component and add to manager
	function Entity:createComponent(class, ...)
		return self:addComponent(class:new(...), ...)
	end

	--- Remove component from entity
	-- @param Component component
	function Entity:removeComponent(component, ...)
		assert(component:isInstanceOf(Component), 'not a subclass of Component')
		if self.components:remove(component) then
			self.components.class[component.___class] = self.components.class[component.___class] - 1
			return component.removed and component:removed(self, ...)
		end
		return false
	end

	---
	function Entity:clearComponents()
		for _, component in self.components:enum() do
			self:removeComponent(component)
		end
		self.components:reset()
		self.components.class = { }
		return true
	end

	--- Check if component exists on entity
	-- @param Component component
	function Entity:hasComponent(component)
		return self.components:has(component)
	end

	--- Check if component exists on entity
	-- @param Component componentClass
	function Entity:hasComponentClass(componentClass)
		return self.components.class[componentClass] and self.components.class[componentClass] > 0 or false
	end

	--- Get attached component by id
	function Entity:getComponentById(id)
		return self.components:getById(id)
	end

	--- Get a single attached component of given class
	function Entity:getComponent(componentClass)
		assert(componentClass, 'no component specified')
		for id, value in self.components:enum() do
			if value:isInstanceOf(componentClass) then
				return value:wrap(self)
			end
		end
		return nil
	end

	--- Get a list of attached components of given class
	function Entity:getComponents(componentClass)
		local list = {}
		for id, value in self.components:enum() do
			if not componentClass or value:isInstanceOf(componentClass) then
				list[#list + 1] = value:wrap(self)
			end
		end
		return list
	end

	--- Enumeration entities' tree
	--  @param boolean active  enumerate only active nodes
	--  @param boolean skipped  skip self in enumeration
	--  @return function
	function Entity:enum(active, skipped)
		local beginner = self
		if not (beginner and (beginner.nodes or beginner.getNodes)) then return dummy end
		beginner = skipped and beginner:getNodes() or { beginner }
		local tasks = { { beginner, 0, #beginner } }
		local depth = 1
		local i = 0
		local current = tasks[depth]
		return function ()
			while i < current[3] or depth > 1 do
				i = i + 1
				local returned = current[1][i]
				local nodes = returned and returned:getNodes()
				if returned and nodes and next(nodes) then
					if not active or returned.active then
						current[2] = i
						current = { nodes, 0, #nodes }
						tasks[#tasks + 1] = current
						depth = depth + 1
						i = 0
					end
				elseif i >= current[3] and depth > 1 then
					depth = depth - 1
					current = tasks[depth]
					i = current[2]
				end
				if not active or returned and returned.active then
					return returned
				end
			end
			return nil
		end
	end

return Entity
