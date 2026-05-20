require 'spec_helper'

local Input = l2df.import 'manager.input'
local Recorder = l2df.import 'manager.recorder'

describe('manager.recorder', function()
	local path = 'tests/fixtures/recorder_spec.replay'

	before_each(function()
		os.remove(path)
		Input {
			keys = { 'up', 'down', 'attack' },
			mappings = {
				{ up = 'w', down = 's', attack = 'space' },
			},
		}
		Input:unlock()
		Input:reset(0)
		Recorder:stop()
	end)

	after_each(function()
		Recorder:stop()
		os.remove(path)
	end)

	it('rewrites snapshot recordings after input history changes', function()
		Input:addinput(1, 1, 1)
		Input:addinput(3, 1, 2)

		Recorder:start(path, 'meta', nil, 0)
		Recorder:update(0, true)

		Input:dropinput(1, 1)
		Input:addinput(5, 1, 2)
		Recorder:update(0, true)
		Recorder:stop(path)

		local metadata = nil
		assert.is_true(Recorder:open(path, function (meta)
			metadata = meta
			return 0
		end))

		assert.are.equal('meta', metadata)
		assert.are.equal(5, Input:lastinput(1).data)
		assert.are.equal(2, Input:lastinput(1).frame)
	end)
end)
