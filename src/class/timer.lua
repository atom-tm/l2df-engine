--- Timer class
-- @classmod l2df.class.timer
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Timer works only with l2df v1.0 and higher')

local Class = core.import 'class'
local EventManager = core.import 'manager.event'

local Timer = Class:extend()

    function Timer:init(tick)
        self.i = 0
        self.tick = tick
        EventManager:subscribe('update', self.update, nil, self)
    end

    function Timer:update(dt, islast)
        self.i = self.i + 1
        if self.i >= self.tick then
            EventManager:invoke('timer', self)
            self.i = 0
        end
    end

return Timer