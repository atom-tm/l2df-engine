require 'spec_helper'

local Entity = l2df.import 'class.entity'
local Frames = l2df.import 'class.component.frames'

describe('class.component.frames', function()
	it('maps frame keywords, clones frame data, and advances by wait', function()
		local idle = {
			1,
			'idle',
			wait = 1,
			next = 'run',
			pose = 'standing',
			nested = { value = 4 },
		}
		local run = {
			2,
			'run',
			wait = 0,
			next = 'run',
			pose = 'running',
		}
		local entity = Entity:new()
		local component = Frames:new()

		entity:addComponent(component, {
			frame = 'idle',
			frames = { idle, run },
		})

		local size, wait, id, next_frame, counter = entity.C.frames:stats()
		assert.are.equal(2, size)
		assert.are.equal(1, wait)
		assert.are.equal(1, id)
		assert.are.equal('run', next_frame)
		assert.are.equal(0, counter)

		entity.C.frames:preupdate()
		assert.are.equal('standing', entity.data.pose)
		entity.data.nested.value = 99
		assert.are.equal(4, idle.nested.value)

		entity.C.frames:preupdate()
		entity.C.frames:preupdate()

		assert.are.equal(2, entity.data.frame.id)
		assert.are.equal('running', entity.data.pose)
	end)

	it('adds and removes transient state fields on each preupdate', function()
		local entity = Entity:new()
		local component = Frames:new()

		entity.data.persisted = 'base'
		entity:addComponent(component, {
			frame = 1,
			frames = {
				{ id = 1, wait = 0, next = 1, persisted = 'frame', temporary = 'value' },
			},
		})

		entity.C.frames:preupdate()
		assert.are.equal('frame', entity.data.persisted)
		assert.are.equal('value', entity.data.temporary)

		entity.C.frames:preupdate()
		assert.are.equal('frame', entity.data.persisted)
		assert.are.equal('value', entity.data.temporary)
	end)
end)
