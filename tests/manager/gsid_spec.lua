require 'spec_helper'

local GSID = l2df.import 'manager.gsid'

describe('manager.gsid', function()
	before_each(function()
		GSID { seed = 7, salt = 3, step = 2 }
	end)

	it('generates deterministic ids and restores snapshots', function()
		assert.are.equal('4A8994AF', GSID:generate())
		assert.are.equal('2778F95E', GSID:generate())

		local snapshot = GSID.sync()
		local third = GSID:generate()

		GSID.sync(snapshot)
		assert.are.equal(third, GSID:generate())
	end)

	it('advances state by fixed steps and resets the counter to salt', function()
		GSID:advance(2)

		local state = GSID.sync()

		assert.are.equal(8, state.state)
		assert.are.equal(3, state.counter)
		assert.are.equal(GSID:hash(8, 3), GSID:generate())
	end)

	it('returns a repeatable bounded rand sequence across advances', function()
		local tickrate = 1 / 60
		local first = { }
		local second = { }

		GSID { seed = 1, salt = 1, step = tickrate }
		for i = 1, 20 do
			GSID:advance(tickrate)
			first[i] = GSID:rand() % 100 + 1
			assert.is_true(first[i] >= 1 and first[i] <= 100)
		end

		GSID { seed = 1, salt = 1, step = tickrate }
		for i = 1, 20 do
			GSID:advance(tickrate)
			second[i] = GSID:rand() % 100 + 1
		end

		assert.are.same(first, second)
	end)
end)
