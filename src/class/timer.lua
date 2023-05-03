--- Timer class. Inherited from @{l2df.class|l2df.Class}.
-- @classmod l2df.class.timer
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Timer works only with l2df v1.0 and higher')

local Class = core.import 'class'
local EventManager = core.import 'manager.event'

local type = _G.type

local Timer = Class:extend()

    --- Init timer.
    -- @param number tick  Number of frames to wait for.
    -- @param[opt] function callback Callback function.
    function Timer:init(tick, callback)
        self.i = 0
        self.tick = tick
        self.id = EventManager:subscribe('update', self.update, nil, self)
        if type(callback) == 'function' then
            self.trigger = callback
        end
    end

    --- Update event handler.
    -- @param number dt  Delta time from the previous frame update.
    -- @param boolean islast  Accepts only updates for the last drawn frame.
    function Timer:update(dt, islast)
    	if not islast then return end
        self.i = self.i + 1
        if self.i >= self.tick then
            self:trigger()
            self.i = 0
        end
    end

    --- Triggers `timer` event.
    function Timer:trigger()
        EventManager:invoke('timer', self)
    end

    --- Disposes timer object by unsubscribing it from @{l2df.manager.event|EventManager}
    function Timer:dispose()
        EventManager:unsubscribeById('update', self.id)
    end

return Timer