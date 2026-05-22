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

	it('coalesces local button changes in the same frame', function()
		Input:advance()
		Input:keypressed('w')
		Input:keypressed('space')
		Input:update(1 / 60, true)

		local expected = Input:encode({ up = true, attack = true })
		local last = Input:lastinput(1)
		assert.are.equal(1, last.frame)
		assert.are.equal(expected, last.data)
		assert.is_nil(last.next)

		local player, frame, input = Input:replaystream()()
		assert.are.equal(1, player)
		assert.are.equal(1, frame)
		assert.are.equal(expected, input)
		assert.is_true(Input:hitted('up', 1, true))
		assert.is_true(Input:hitted('attack', 1, true))
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

	it('rehashes later input after a same-frame local replacement', function()
		Input:addinput(1, 1, 1)
		Input:addinput(3, 1, 2)
		Input:addinput(5, 1, 1, true)

		local rewritten = Input:lastinput(1)
		assert.are.equal(2, rewritten.frame)
		assert.are.equal(3, rewritten.data)
		assert.are.equal(6, rewritten.changes)

		Input:reset(0)
		Input:addinput(5, 1, 1)
		Input:addinput(3, 1, 2)

		local rebuilt = Input:lastinput(1)
		assert.are.equal(rebuilt.hash, rewritten.hash)
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

	it('allocates synthetic bot slots after real local and remote players', function()
		Input:reset(2)

		local bot1 = Input:newBotPlayer()
		local bot2 = Input:newBotPlayer()

		assert.are.equal(1, Input.localplayers)
		assert.are.equal(2, Input.remoteplayers)
		assert.are.equal(2, Input.botplayers)
		assert.are.equal(5, Input:totalplayers())
		assert.are.equal(3, Input:remoteplayerend())
		assert.are.equal(4, bot1)
		assert.are.equal(5, bot2)
	end)

	it('keeps default button scans scoped to real players while bot slots remain explicit', function()
		Input:reset(1)
		local bot = Input:newBotPlayer()
		Input:setrawinput(Input:encode({ attack = true }), bot, 1)
		Input.frame = 1
		Input:update(1 / 60, true)

		assert.is_false(Input:pressed('attack'))
		assert.is_true(Input:pressed('attack', bot))
	end)

	it('includes synthetic bots in replay streams and can clear them', function()
		Input:reset(1)
		local bot = Input:newBotPlayer()
		Input:setrawinput(Input:encode({ attack = true }), bot, 2)

		local player, frame, input = Input:replaystream()()
		assert.are.equal(bot, player)
		assert.are.equal(2, frame)
		assert.are.equal(Input:encode({ attack = true }), input)

		Input:clearBotPlayers()
		assert.are.equal(0, Input.botplayers)
		assert.are.equal(2, Input:totalplayers())
		assert.are.equal(1, Input.remoteplayers)
	end)

	it('replaces future synthetic input without conflict', function()
		Input:reset(0)
		local bot = Input:newBotPlayer()
		Input:setrawinput(Input:encode({ up = true }), bot, 2)
		Input:setrawinput(Input:encode({ down = true }), bot, 2)

		local last = Input:lastinput(bot)
		assert.are.equal(2, last.frame)
		assert.are.equal(Input:encode({ down = true }), last.data)
		assert.is_nil(last.next)
	end)

	it('reports queued synthetic input as hitted on its frame', function()
		Input:reset(0)
		local bot = Input:newBotPlayer()
		Input:setrawinput(Input:encode({ attack = true }), bot, Input.frame + 1)

		Input:advance()
		Input:update(1 / 60, true)

		local hit, player = Input:hitted('attack', bot)
		assert.is_true(hit)
		assert.are.equal(bot, player)

		Input:advance()
		Input:update(1 / 60, true)

		assert.is_true(Input:pressed('attack', bot))
		assert.is_false(Input:hitted('attack', bot))
	end)
end)
