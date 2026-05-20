require 'spec_helper'

local Logger = l2df.import 'class.logger'
local Input = l2df.import 'manager.input'

describe('manager.input', function()
	before_each(function()
		Logger.level = 'crit'
		Input {
			keys = { 'up', 'down', 'attack' },
			mappings = {
				{ up = 'w', down = 's', attack = 'space' },
			},
		}
		Input:unlock()
		Input:reset(0)
	end)

	after_each(function()
		Logger.level = 'debug'
	end)

	it('maps key events to raw input and consume checks', function()
		Input:advance()
		Input:keypressed('w')
		Input:update(1 / 60, true)

		assert.are.equal(1, Input:rawinput(1))
		assert.is_true(Input:pressed('up', 1, true))

		local hit, player = Input:hitted('up', 1, true)
		assert.is_true(hit)
		assert.are.equal(1, player)

		local consumed = Input:consume('up', 1, true)
		local consumed_again = Input:consume('up', 1, true)
		assert.is_true(consumed)
		assert.is_false(consumed_again)

		Input:advance()
		Input:keyreleased('w')
		Input:update(1 / 60, true)
		assert.are.equal(0, Input:rawinput(1))
		assert.is_false(Input:pressed('up', 1, true))
	end)

	it('stores deterministic input chains and can drop future input', function()
		Input:addinput(1, 1, 1)
		Input:addinput(3, 1, 2)

		local last = Input:lastinput(1)
		assert.are.equal(2, last.frame)
		assert.are.equal(3, last.data)
		assert.are.equal(276208192, last.hash)

		local dropped, current = Input:dropinput(1, 1)
		assert.is_true(dropped)
		assert.are.equal(1, current.frame)
		assert.are.equal(1, Input:lastinput(1).frame)
	end)

	it('keeps hashes stable when duplicate payloads contain conflicts', function()
		Input {
			keys = { 'up', 'down', 'left', 'right', 'attack', 'jump', 'defend', 'special', 'select' },
		}
		Input:reset(1)

		local payload = {
			inputs = { 1, 8, 0, 9, 4 },
			frames = { 1, 2, 3, 9, 9 },
		}
		local previous_hash = nil
		local current = nil

		for _ = 1, 10 do
			for i = 1, #payload.inputs do
				_, current = Input:addinput(payload.inputs[i], 1, payload.frames[i])
			end
			assert.is_true(previous_hash == nil or previous_hash == current.hash)
			previous_hash = current.hash
		end

		assert.are.equal('D1637BE7', string.format('%08X', current.hash))
	end)
end)
