local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Entities works only with l2df v1.0 and higher")

local Class = core.import "core.class"
local Component = core.import "core.class.component"

local tableRemove = table.remove

local Entity = Class:extend({ ___groups = { }, components = { }, has_components = { }, nodes = { }})

	function Entity:isParent(object)
		assert(object:isInstanceOf(Entity), "not a subclass of Entities")
		for i = 1, #self.nodes do
			if self.nodes[i] == object then return true end
		end
		return false
	end

	nodes = {
		1 kjhj,
		2 hkj,
		3
		4 lkjlkj,
		5kljlkj,
		6 llkhkj
	}

	function Entity:addChild(object)
		assert(object:isInstanceOf(Entity), "not a subclass of Entities")
		if self:isParent(object) then return end
	end


	function Entity:removeNode(id)



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