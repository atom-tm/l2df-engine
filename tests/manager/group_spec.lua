require 'spec_helper'

local Entity = l2df.import 'class.entity'
local GroupManager = l2df.import 'manager.group'

describe('manager.group', function()
	it('adds, removes, and queries tags for objects', function()
		local prefix = 'group_spec_' .. tostring({})
		local room = { id = 1 }
		local other = { id = 2 }
		local number = 228

		GroupManager.addTags(room, { prefix .. '_entity', prefix .. '_room', prefix .. '_shared' })
		GroupManager.addTags(other, { prefix .. '_entity', prefix .. '_shared' })
		GroupManager.addTags(number, { prefix .. '_number', prefix .. '_shared' })
		GroupManager.removeTags(other, prefix .. '_shared')

		assert.is_true(GroupManager.hasTags(room, { prefix .. '_room', prefix .. '_shared' }))
		assert.is_false(GroupManager.hasTags(other, prefix .. '_shared'))
		assert.are.same({ prefix .. '_number', prefix .. '_shared' }, GroupManager.getTags(number))

		local shared = GroupManager:getByTag(prefix .. '_shared')
		assert.are.equal(2, #shared)
		assert.are.equal(room, shared[1])
		assert.are.equal(number, shared[2])
	end)

	it('filters tagged objects without duplicating matches', function()
		local prefix = 'group_spec_filter_' .. tostring({})
		local first = { active = true }
		local second = { active = false }
		local third = { active = true }

		GroupManager.addTags(first, { prefix .. '_shared', prefix .. '_first' })
		GroupManager.addTags(second, { prefix .. '_shared', prefix .. '_second' })
		GroupManager.addTags(third, { prefix .. '_other', prefix .. '_first' })

		local matches = GroupManager:getByFilter(
			{ prefix .. '_shared', prefix .. '_first' },
			function(obj)
				return obj.active
			end
		)

		assert.are.equal(2, #matches)
		assert.are.equal(first, matches[1])
		assert.are.equal(third, matches[2])
	end)

	it('tracks initialized entity classes and installs tag helpers', function()
		local Actor = Entity:extend()
		local actor = Actor:new()

		GroupManager:classInit(actor)
		actor:addTags('actor_tag')

		assert.is_true(actor:hasTags('actor_tag'))
		assert.are.same({ actor }, GroupManager:getByClass(Actor))
		assert.are.same({ actor }, GroupManager:getByInstance(Actor))
	end)
end)
