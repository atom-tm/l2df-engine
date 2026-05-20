require 'spec_helper'

local Entity = l2df.import 'class.entity'
local States = l2df.import 'class.component.states'
local StatesManager = l2df.import 'manager.states'

describe('class.component.states', function()
	it('runs transient states once and constant states repeatedly', function()
		local state_path = 'tests/fixtures/states/7.lua'
		local file = io.open(state_path, 'rb')
		if file then
			file:close()
		end
		StatesManager:add(state_path)

		local entity = Entity:new()
		local component = States:new()

		entity:addComponent(component, {
			constates = {
				{ 7, field = 'constant_runs' },
			},
		})
		entity.C.states.add({ 7, field = 'state_runs' })

		assert.is_true(entity.C.states.has(7))

		entity.C.states.update(1 / 60)
		entity.C.states.update(1 / 60)

		assert.are.equal(1, entity.data.state_runs)
		assert.are.equal(2, entity.data.constant_runs)
	end)
end)
