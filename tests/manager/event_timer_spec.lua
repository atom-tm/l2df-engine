require 'spec_helper'

local EventManager = l2df.import 'manager.event'
local Timer = l2df.import 'class.timer'

describe('manager.event', function()
	it('invokes subscribers with source filtering and fixed params', function()
		local event = 'spec_event_' .. tostring({})
		local source = { id = 'source' }
		local other = { id = 'other' }
		local calls = { }

		local id = EventManager:subscribe(event, function(prefix, value)
			calls[#calls + 1] = prefix .. value
		end, source, 'seen:')

		EventManager:invoke(event, other, 'ignored')
		EventManager:invoke(event, source, 'ok')

		assert.are.same({ 'seen:ok' }, calls)
		assert.is_truthy(EventManager:unsubscribeById(event, id))

		EventManager:invoke(event, source, 'again')
		assert.are.same({ 'seen:ok' }, calls)
	end)
end)

describe('class.timer', function()
	it('triggers only on accepted update frames', function()
		local fired = 0
		local timer = Timer:new(2, function()
			fired = fired + 1
		end)

		timer:update(1 / 60, false)
		timer:update(1 / 60, true)
		timer:update(1 / 60, true)
		timer:update(1 / 60, true)

		assert.are.equal(1, fired)
		timer:dispose()
	end)
end)
