--- RemoteController component
-- @classmod l2df.class.component.controller.remote
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'RemoteController works only with l2df v1.0 and higher')

local Controller = core.import 'class.component.controller'
local InputManager = core.import 'manager.input'
local NetworkManager = core.import 'manager.network'

NetworkManager:event('netinput', 'Id', function (c, e, input, time)
	if c.player then
		InputManager:addinput(input, c.player, time)
	end
end)

local RemoteController = Controller:extend()

	--- Check if button is pressed
	-- @param string button  Pressed button
	-- @return boolean
	function RemoteController:pressed(button)
		return InputManager:pressed(button, self.entity.vars.player)
	end

	--- Update controller timers
	function RemoteController:update(dt, islast)
		if not self.entity then return end

		local vars = self.entity.vars
	end

return RemoteController