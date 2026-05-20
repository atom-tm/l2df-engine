require 'spec_helper'

local Component = l2df.import 'class.component'
local Entity = l2df.import 'class.entity'

describe('class.entity', function()
	it('attaches nodes, exposes keyed references, and enumerates the tree', function()
		local root = Entity:new({ }, 'root')
		local child = Entity:new({ }, 'child')
		local grandchild = Entity:new({ }, 'grandchild')

		root:attach(child)
		child:attach(grandchild)

		assert.are.equal(root, child:getParent())
		assert.are.equal(child, root.R.child())
		assert.are.equal(grandchild, root.R.child.grandchild())
		assert.is_true(grandchild:isDescendant(root))

		local keys = { }
		for node in root:enum() do
			keys[#keys + 1] = node.key
		end

		assert.are.same({ 'root', 'child', 'grandchild' }, keys)
	end)

	it('propagates active state through descendants', function()
		local root = Entity:new()
		local child = Entity:new()
		local grandchild = Entity:new()

		root:attach(child)
		child:attach(grandchild)

		assert.is_true(root:setActive(false, true))
		assert.is_false(root.active)
		assert.is_false(child.active)
		assert.is_false(grandchild.active)

		assert.is_true(root:setActive(true, true))
		assert.is_true(child.active)
		assert.is_true(grandchild.active)
	end)
end)

describe('class.component', function()
	it('wraps component methods with entity context and stores component data', function()
		local Health = Component:extend()

		function Health:added(obj, kwargs)
			obj.C.health = self:wrap(obj)
			self:data(obj).hp = kwargs.hp
		end

		function Health:removed(obj)
			self.super.removed(self, obj)
			obj.C.health = nil
		end

		function Health:damage(obj, amount)
			local data = self:data(obj)
			data.hp = data.hp - amount
			return data.hp
		end

		local entity = Entity:new()
		local component = Health:new()

		entity:addComponent(component, { hp = 10 })

		assert.are.equal(1, entity:hasComponent(component))
		assert.is_true(entity:hasComponentClass(Health))
		assert.are.equal(entity, entity.C.health.object)
		assert.are.equal(7, entity.C.health.damage(3))
		assert.are.equal(7, component:data(entity).hp)

		assert.is_nil(entity:removeComponent(component))
		assert.is_nil(entity.C.health)
		assert.is_false(entity:hasComponent(component))
	end)
end)
