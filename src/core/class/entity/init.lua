local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Class = core.import 'core.class'
local Component = core.import 'core.class.component'
local Storage = core.import 'core.class.storage'

local tableRemove = table.remove

local Entity = Class:extend()

	--- Creating a entity instance
	function Entity:new(...)
		local obj = self:___getInstance()
		obj.nodes = Storage:new()
		obj.components = Storage:new()
		obj.components.class = { }
		obj.id = nil
		obj.parent = nil
		obj.active = true
		obj.vars = { }
		obj:init(...)
		return obj
	end

	--- Adding an inheritor to an object
	function Entity:attach(entity)
		assert(entity:isInstanceOf(Entity), 'not a subclass of Entity')
		if self:isAncestor(entity) then return false end
		if entity.parent then entity.parent:detach(entity) end
		entity.parent = self
		entity:setActive(self.active)
		return self.nodes:add(entity)
	end

	--- Adding some inheritors to an object
	function Entity:attachMultiple(array)
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

	--- Removing object from inheritors list of his parent
	function Entity:detachParent()
		self.parent:detach(self)
	end

	--- Getting a list of object inheritors
	function Entity:getNodes()
		local list = {}
		for id, key in self.nodes:enum(true) do
			list[#list + 1] = key
		end
		return list
	end

	--- Option to obtain a parent using the function
	function Entity:getParent()
		return self.parent
	end

	--- Check for inheritance from an object
	function Entity:isAncestor(entity)
		local object = self
		while object do
			if object == entity then return true end
			object = object.parent
		end
		return false
	end

	---
	function Entity:setActive(bool)
		local active = bool
		if bool == nil then active = not self.active end
		if self.parent and not (self.parent.active) and active then return end
		local em = core.import 'core.manager.entity'
		for object in em:enum(self) do
			object.active = active
		end
		return true
	end

	--- Add component to entity
	-- @param component, Component
	function Entity:addComponent(component, ...)
		assert(component:isInstanceOf(Component), 'not a subclass of Component')
		if self:hasComponent(component) then return false end
		if component.unique and self:hasComponentClass(component.___class) then return false end
		self.components.class[component.___class] = self.components.class[component.___class] and self.components.class[component.___class] + 1 or 1
		return self.components:add(component), component, component.added and component:added(self, self.vars, ...)
	end

	--- Create new component and add to manager
	function Entity:createComponent(class, ...)
		return self:addComponent(class:new(...),...)
	end

	--- Remove component from entity
	-- @param component, Component
	function Entity:removeComponent(component, ...)
		assert(component:isInstanceOf(Component), 'not a subclass of Component')
		if self.components:remove(component) then
			self.components.class[component.___class] = self.components.class[component.___class] - 1
			return component:removed(self, self.vars, ...)
		end
		return false
	end

	--- Check if component exists on entity
	-- @param component, Component|function
	function Entity:hasComponent(component)
		return self.components:has(component)
	end

	--- Check if component exists on entity
	-- @param component, Component|function
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
				return value
			end
		end
		return nil
	end

	--- Get a list of attached components of given class
	function Entity:getComponents(componentClass)
		local list = {}
		for id, value in self.components:enum() do
			if not componentClass or value:isInstanceOf(componentClass) then
				list[#list + 1] = value
			end
		end
		return list
	end

return Entity