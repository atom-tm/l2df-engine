require 'spec_helper'

local Entity = l2df.import 'class.entity'
local Factory = l2df.import 'manager.factory'

describe('manager.factory', function()
	it('creates registered entity classes by name', function()
		local Room = Entity:extend({ name = 'factory_spec_room' })

		function Room:init(kwargs)
			self.data.value = kwargs.value
		end

		assert.is_true(Factory:add(Room))

		local room = Factory:create('factory_spec_room', { value = 42 })

		assert.is_true(room:isInstanceOf(Room))
		assert.are.equal(42, room.data.value)
	end)

	it('recursively creates typed nested data', function()
		local Marker = Entity:extend({ name = 'factory_spec_marker' })

		function Marker:init(kwargs)
			self.data.label = kwargs.label
		end

		Factory:add(Marker)

		local result = Factory:create({
			child = {
				_type = 'factory_spec_marker',
				label = 'nested',
			},
		})

		assert.is_true(result.child:isInstanceOf(Marker))
		assert.are.equal('nested', result.child.data.label)
	end)
end)
