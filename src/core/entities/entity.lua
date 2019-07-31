local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Core.Entities.Entity works only with l2df v1.0 and higher")

local Object = core.import "core.object"
local Component = core.import "core.entities.component"

local table_remove = table.remove

local Entity = Object:extend({ ___groups = { }, components = { }, has_components = { }, childs = { } })

	--- Add component to entity
	-- @param component, Component|function
	function Entity:addComponent(component)
		assert(type(component) == "function" or component:isInstanceOf(Component), "not a subclass of Entities.Component")
		if self.has_components[component] then return end

		rawset(self.components, #self.components + 1, component(entity))
		self.has_components[component] = true
	end

	--- Remove component from entity
	-- @param component, Component|function
	function Entity:removeComponent(component)
		if not self.has_components[component] then return end

		for i = #self.component, 1, -1 do
			if self.components[i] == component then
				table_remove(self.components, i)
				break
			end
		end
		self.has_components[component] = nil
	end

	--- Check if component exists on entity
	-- @param component, Component|function
	function Entity:hasComponent(component)
		return self.has_components[component] and true or false
	end

return Entity