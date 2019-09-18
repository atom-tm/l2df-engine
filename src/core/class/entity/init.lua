local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local Class = core.import "core.class"
local Component = core.import "core.class.component"
local Storage = core.import "core.class.storage"

local tableRemove = table.remove

local Entity = Class:extend({ ___groups = { }, components = { }, has_components = { }, nodes = Storage:new(), id = nil, parent = nil })

	--- Adding an inheritor to an object
	function Entity:attach(entity)
		assert(entity:isInstanceOf(Entity), "not a subclass of Entity")
		if entity.parent then entity.parent:removeChild(entity) end
		local id = self.nodes:add(entity)
		entity.parent = self
	end

	--- Adding some inheritors to an object
	function Entity:attachMulti(array)
		for i = 1, #array do
			if array[i]:isInstanceOf(Entity) then
				self:addChild(array[i])
			end
		end
	end

	--- Removing an inheritor from object
	function Entity:detach(entity)
		assert(entity:isInstanceOf(Entity), "not a subclass of Entity")
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
		for id, key in self.nodes:enum() do
			list[#list + 1] = key
		end
		return list
	end

	function Entity:getParent()
		return self.parent
	end

	function Entity:showNodes()
		for id, key in self.nodes:enum() do
			print(id .. " " .. tostring(key))
		end
	end

	--- Add component to entity
	-- @param component, Component
	function Entity:addComponent(component)
		assert(component:isInstanceOf(Component), "not a subclass of Component")
		if self.has_components[component] then return end

		rawset(self.components, #self.components + 1, component(self))
		self.has_components[component] = true
	end

	--- Remove component from entity
	-- @param component, Component
	function Entity:removeComponent(component)
		if not self.has_components[component] then return end
		for i = #self.component, 1, -1 do
			if self.components[i] == component then
				tableRemove(self.components, i)
				break
			end
		end
		self.has_components[component] = nil
	end

	--- Get component from entity
	-- @param component, Component
	function Entity:getComponent(component)
		if not self.has_components[component] then return false end
		for i = #self.components, 1, -1 do
			if self.components[i] == component then
				return self.components[i]
			end
		end
		return false
	end

	--- Check if component exists on entity
	-- @param component, Component|function
	function Entity:hasComponent(component)
		return self.has_components[component] and true or false
	end


return Entity