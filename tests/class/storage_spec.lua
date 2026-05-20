require 'spec_helper'

local Storage = l2df.import 'class.storage'
local OrderedStorage = l2df.import 'class.storage.ordered'

describe('class.storage', function()
	it('adds, removes, and reuses free ids', function()
		local storage = Storage:new()
		local first = { name = 'first' }
		local second = { name = 'second' }
		local third = { name = 'third' }

		local first_id = storage:add(first)
		local second_id = storage:add(second)

		assert.are.equal(1, first_id)
		assert.are.equal(2, second_id)
		assert.are.equal(2, storage.count)
		assert.are.equal(first, storage:getById(first_id))
		assert.are.equal(first_id, storage:has(first))

		assert.are.equal(first_id, storage:remove(first))
		assert.are.equal(1, storage.count)
		assert.is_false(storage:getById(first_id))

		local third_id = storage:add(third)
		assert.are.equal(first_id, third_id)
		assert.are.equal(third, storage:getById(third_id))
	end)

	it('stores and retrieves keyed objects', function()
		local storage = Storage:new()
		local player = { hp = 100 }

		local id = storage:addByKey(player, 'player')

		assert.are.equal(player, storage:getByKey('player'))
		assert.are.equal(player, storage:getById(id))
		assert.are.same({ [id] = player }, storage.data)
	end)

	it('enumerates sparse data with optional nil skipping', function()
		local storage = Storage:new()
		storage:add('one')
		storage:add('two')
		storage:add('three')
		storage:removeById(2)

		local dense = { }
		for _, value in storage:enum(true) do
			dense[#dense + 1] = value
		end

		assert.are.same({ 'one', 'three' }, dense)
	end)
end)

describe('class.storage.ordered', function()
	it('enumerates values by sorted id', function()
		local storage = OrderedStorage:new()

		storage:addById('middle', 20)
		storage:addById('first', 10)
		storage:addById('last', 30)

		local values = { }
		for id, value in storage:enum() do
			values[#values + 1] = { id, value }
		end

		assert.are.same({
			{ 10, 'first' },
			{ 20, 'middle' },
			{ 30, 'last' },
		}, values)
	end)

	it('keeps count in sync when removing objects', function()
		local storage = OrderedStorage:new()

		storage:addById('first', 10)
		storage:addById('second', 20)

		assert.are.equal(2, storage.count)
		assert.is_true(storage:removeById(10))
		assert.are.equal(1, storage.count)
		assert.is_true(storage:remove('second'))
		assert.are.equal(0, storage.count)
	end)
end)
