require 'spec_helper'

local Entity = l2df.import 'class.entity'
local Transform = l2df.import 'class.transform'
local TransformComponent = l2df.import 'class.component.transform'

local function assert_near(expected, actual)
	assert.is_true(math.abs(expected - actual) < 1e-9)
end

describe('class.transform', function()
	it('applies translation and scale to vectors', function()
		local transform = Transform:new(10, 20, 0, 2, 3, 1, 0)
		local vector = transform:vector(1, 1, 0)

		assert.are.equal(12, vector[1][1])
		assert.are.equal(23, vector[2][1])
		assert.are.equal(0, vector[3][1])
	end)

	it('rotates vectors in degrees', function()
		local transform = Transform:new()
		transform:rotate(90)

		local vector = transform:vector(1, 0, 0)

		assert_near(0, vector[1][1])
		assert_near(1, vector[2][1])
	end)

	it('clones and appends transforms independently', function()
		local parent = Transform:new(10, 0, 0)
		local child = Transform:new(0, 5, 0)
		local clone = parent:clone()

		parent:append(child)
		parent:translate(1, 1, 0)

		local parent_vector = parent:vector(0, 0, 0)
		local clone_vector = clone:vector(0, 0, 0)

		assert.are.same({ { 11 }, { 6 }, { 0 }, { 1 } }, parent_vector)
		assert.are.same({ { 10 }, { 0 }, { 0 }, { 1 } }, clone_vector)
	end)
end)

describe('class.component.transform', function()
	it('propagates parent transform data to child globals', function()
		local parent = Entity:new()
		local child = Entity:new()

		parent:attach(child)
		parent:addComponent(TransformComponent:new(), { x = 10, y = 5 })
		child:addComponent(TransformComponent:new(), { x = 2, y = 3, scalex = 2 })

		parent.C.transform:liftdown()
		child.C.transform:update()
		parent.C.transform:liftup()

		assert.are.equal(12, child.data.globalX)
		assert.are.equal(8, child.data.globalY)
		assert.are.equal(2, child.data.globalScaleX)
		assert.are.equal(1, child.data.globalScaleY)
	end)
end)
