--- Entity class. Inherited from @{l2df.class|l2df.Class}.
-- @classmod l2df.class.entity
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local Class = core.import 'class'
local Component = core.import 'class.component'
local Storage = core.import 'class.storage'

local assert = _G.assert
local require = _G.require
local setmetatable = _G.setmetatable
local default = helper.notNil
local copyTable = helper.copyTable
local isArray = helper.isArray
local dummy = function () return nil end

local Entity = Class:extend()

	--- Meta-table for performing search in sub-nodes of the entity object.
	-- @field function __index  Doing search. Ex.: `local btn_ref = Entity.R.MENU.BUTTON`
	-- @field function __newindex  Set object key after search. Ex.: `Entity.R.MENU.BUTTON.text = 'Click'`
	-- @field function __call  Returns "clear" @{l2df.class.entity|entity} object.
	-- Important cuz @{l2df.class.entity.R|Entity.R} variable is not an actual entity. Ex.: `local btn = Entity.R.MENU.BUTTON()`
	-- @table Entity.R

	--- Table containing components for easy access.
	-- Components must manually add / remove them from this list if it is required.
	-- @table Entity.C

	--- Entity's public storage for all variables and user data.
	-- It is important to use this and do not garbage actual entity's table since:<br>
	-- 1. It's more secure;<br>
	-- 2. It's used by all the components to store and transfer data;<br>
	-- 3. It's a part of rollback system;<br>
	-- 4. Networking doesn't work without this!
	-- @table Entity.data

	--- Key string. Used for searching via @{l2df.class.entity.R|Entity.R}.
	-- @string Entity.key

	--- Parent entity. Can be `nil` meaning no parent attached.
	-- @field l2df.class.entity Entity.parent

	--- Entity's state.
	-- If false entity would not receive any update and draw events.
	-- @field boolean Entity.active

	--- Constructor for eating an entity instance.
	-- @param[opt] table kwargs  Keyword arguments. Also passed to all adding components.
	-- @param[opt=true] boolean kwargs.active  See @{l2df.class.entity.active|Entity.active}.
	-- @param[opt] table kwargs.components  Array of @{l2df.class.component|components} to add on entity creation.
	-- @param[opt] string key  String key used for performing entity-search via @{l2df.class.entity.R|Entity.R} meta-variable.
	-- @param ... ...  Arguments redirected to @{l2df.class.init|Entity:init()} function.
	function Entity:new(kwargs, key, ...)
		kwargs = kwargs or { }
		local obj = self:___getInstance()
		obj.key = key
		obj.nodes = Storage:new()
		obj.components = Storage:new()
		obj.components.class = { }
		obj.parent = nil
		obj.active = default(kwargs.active, true)
		obj.data = { ___nomerge = true }
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
		local components = kwargs.components
		if isArray(components) then
			for i = 1, #components do
				if components[i][2] then
					obj:createComponent(require(components[i][1] or components[i]), kwargs)
				else
					obj:addComponent(require(components[i][1] or components[i]), kwargs)
				end
			end
		end
		return obj
	end

	--- Create copy of current object (with all attached nodes).
	-- @return l2df.class.entity
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

	--- Adding an inheritor to an entity.
	-- @param l2df.class.entity entity  Entity to attach.
	-- @return number|boolean
	-- @return l2df.class.entity|nil
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

	--- Adding some inheritors to an entity.
	-- @param table array  Array of @{l2df.class.entity|entities} to attach.
	function Entity:attachMultiple(array)
		array = array or { }
		for i = 1, #array do
			if array[i]:isInstanceOf(Entity) then
				self:attach(array[i])
			end
		end
	end

	--- Removing an inheritor from entity.
	-- @param l2df.class.entity entity  Inheritor to remove.
	function Entity:detach(entity)
		assert(entity:isInstanceOf(Entity), 'not a subclass of Entity')
		self.nodes:remove(entity)
		entity.parent = nil
	end

	--- Remove all nodes attached to the entity.
	function Entity:detachAll()
		for id, node in self.nodes:enum(true) do
			self:detach(node)
		end
	end

	--- Removing entity from inheritors list of his parent.
	-- @return l2df.class.entity
	function Entity:detachParent()
		local parent = self.parent
		if parent then
			parent:detach(self)
		end
		return parent
	end

	--- Destroy entity.
	function Entity:destroy()
		self:clearComponents()
		self:detachParent()
	end

	--- Getting a list of entity's inheritors.
	-- @param[opt] function filter  Filter predicate function.
	-- @return table
	function Entity:getNodes(filter)
		local list = { }
		for id, node in self.nodes:enum(true) do
			if not filter or filter(node) then
				list[#list + 1] = node
			end
		end
		return list
	end

	--- Option to obtain a parent using the function.
	-- @return l2df.class.entity
	function Entity:getParent()
		return self.parent
	end

	--- Backup / restore entity.
	-- @param[opt] table state  Table containing snapshot of the entity's state:
	-- <pre>{ active = [boolean], parent = [@{l2df.class.entity}], data = [table] }</pre>.
	-- @return table|nil
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

	--- Check for inheritance from an object.
	-- @param l2df.class.entity entity  Source entity.
	-- @return boolean
	function Entity:isDescendant(entity)
		local object = self
		while object do
			if object == entity then return true end
			object = object.parent
		end
		return false
	end

	--- Set / toggle active state of this entity.
	-- @param[opt] boolean active  Active state to set. Toggles current if not setted.
	-- @param[opt=false] boolean propagate  Propagates state to subnodes if setted to true.
	-- @return boolean
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

	--- Create new component and add to this entity.
	-- @param l2df.class.component class  Component's class.
	-- @param ... ...  Arguments for @{l2df.class.component.added}.
	-- @return number
	-- @return l2df.class.component
	-- @return boolean
	function Entity:createComponent(class, ...)
		return self:addComponent(class:new(...), ...)
	end

	--- Add component to entity.
	-- @param l2df.class.component component  Component's instance.
	-- @param ... ...  Arguments for @{l2df.class.component.added}.
	-- @return number
	-- @return l2df.class.component
	-- @return boolean
	function Entity:addComponent(component, ...)
		assert(component:isInstanceOf(Component), 'not a subclass of Component')
		if self:hasComponent(component) then return false end
		-- if component.unique and self:hasComponentClass(component.___class) then return false end
		self.components.class[component.___class] = self.components.class[component.___class] and self.components.class[component.___class] + 1 or 1
		return self.components:add(component), component, component.added and component:added(self, ...)
	end

	--- Remove component from entity.
	-- @param l2df.class.component component  Component's instance.
	-- @param ... ...  Arguments for @{l2df.class.component.removed}.
	-- @return boolean
	function Entity:removeComponent(component, ...)
		assert(component:isInstanceOf(Component), 'not a subclass of Component')
		if self.components:remove(component) then
			self.components.class[component.___class] = self.components.class[component.___class] - 1
			return component.removed and component:removed(self, ...)
		end
		return false
	end

	--- Remove all components added to entity.
	-- @return boolean
	function Entity:clearComponents()
		for _, component in self.components:enum() do
			self:removeComponent(component)
		end
		self.components:reset()
		self.components.class = { }
		return true
	end

	--- Floats up existing component of the object like a bubble. Can be used to reorder components execution.
	-- @param l2df.class.component component  Component's instance.
	-- @return number|boolean
	-- @return l2df.class.component|nil
	function Entity:upComponent(component)
		assert(component:isInstanceOf(Component), 'not a subclass of Component')
		if not self:hasComponent(component) then return false end
		self.components:remove(component)
		return self.components:add(component), component
	end

	--- Check if component exists on entity.
	-- @param l2df.class.component component  Component to check.
	-- @return boolean
	function Entity:hasComponent(component)
		return self.components:has(component)
	end

	--- Check if component exists on entity,
	-- @param l2df.class.component componentClass  Component's class to check.
	-- @return boolean
	function Entity:hasComponentClass(componentClass)
		return self.components.class[componentClass] and self.components.class[componentClass] > 0 or false
	end

	--- Get attached component by ID,
	-- @param number id  Component's ID.
	-- @return l2df.class.component
	function Entity:getComponentById(id)
		return self.components:getById(id)
	end

	--- Get a single attached component of given class.
	-- @param l2df.class.component componentClass  Component's class
	-- @return l2df.class.component|nil
	function Entity:getComponent(componentClass)
		assert(componentClass, 'no component specified')
		for id, value in self.components:enum() do
			if value:isInstanceOf(componentClass) then
				return value:wrap(self)
			end
		end
		return nil
	end

	--- Get a list of attached components of given class.
	-- @param l2df.class.component componentClass  Component's class.
	-- @return table
	function Entity:getComponents(componentClass)
		local list = { }
		for id, value in self.components:enum() do
			if not componentClass or value:isInstanceOf(componentClass) then
				list[#list + 1] = value:wrap(self)
			end
		end
		return list
	end

	--- Enumerate entities' tree.
	-- @param[opt=false] boolean active  Enumerate only active nodes.
	-- @param[opt=false] boolean skipped  Skip self in enumeration.
	-- @return function
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
