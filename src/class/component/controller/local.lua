--- LocalController component
-- @classmod l2df.class.component.controller.local
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'LocalController works only with l2df v1.0 and higher')

local Controller = core.import 'class.component.controller'
local NetworkManager = core.import 'manager.network'
local InputManager = core.import 'manager.input'

local LocalController = Controller:extend()

	--- Check if button is pressed
	-- @param string button  Pressed button
	-- @return boolean
	function LocalController:pressed(button)
		return InputManager:pressed(button, self.entity.vars.player)
	end

	--- Update controller timers
	function LocalController:update(dt, islast)
		if not self.entity then return end

		local vars = self.entity.vars
		if islast then
			local input = InputManager:getinput(vars.player)
			if input ~= InputManager:lastinput(vars.player) then
				InputManager:addinput(input, vars.player)
				NetworkManager:broadcast('netinput', input, InputManager.time)
			end
		end

		-- for i = 1, #settings.controls do
		--  if control.players[i] then
		--    local k_pressed = control.players[i].key_pressed
		--    local k_timer = control.players[i].key_timer
		--    local dk_timer = control.players[i].double_key_timer
		--    for key in pairs(settings.controls[i]) do
		--      if love.keyboard.isScancodeDown(settings.controls[i][key]) then
		--        k_pressed[key] = 1
		--      elseif k_pressed[key] > 0 then
		--        k_pressed[key] = k_pressed[key] - 1
		--      end
		--      if k_timer[key] > 0 then
		--        k_timer[key] = k_timer[key] - 1
		--      end
		--      if abs(dk_timer[key]) > 0 then
		--        dk_timer[key] = dk_timer[key] - helper.sign(dk_timer[key])
		--      end
		--    end
		--  end
		-- end
	end

return LocalController