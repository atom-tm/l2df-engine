--- Controller component. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.controller
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Controller works only with l2df v1.0 and higher')

local pairs = _G.pairs

local Component = core.import 'class.component'
local InputManager = core.import 'manager.input'

local Controller = Component:extend()

	--- Component was added to @{l2df.class.entity|Entity} event.
	-- Adds `"controller"` key to the @{l2df.class.entity.C|Entity.C} table.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number player  ID of the player attached to that controller.
	-- @return boolean
	function Controller:added(obj, player)
		if not obj then return false end
		obj.C.controller = self:wrap(obj)
		local data = obj.data
		data.player = player or data.player or 0
		-- TODO: add FSM for combos?
		return true
	end

	--- Component was removed from @{l2df.class.entity|Entity} event.
	-- Removes `"controller"` key from @{l2df.class.entity.C|Entity.C} table.
	-- @param l2df.class.entity obj  Entity's instance.
	function Controller:removed(obj)
		obj.C.controller = nil
	end

	--- Check if button was pressed.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param string button  Pressed button.
	-- @return boolean
	function Controller:pressed(obj, button)
		return InputManager:pressed(button, obj.data.player)
	end

	--- Check if button was double pressed.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param string button  Double pressed button.
	-- @return boolean
	function Controller:doubled(obj, button)
		return InputManager:doubled(button, obj.data.player)
	end

	--- Check if button was pressed at current frame.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param string button  Hitted button.
	-- @return boolean
	function Controller:hitted(obj, button)
		return InputManager:hitted(button, obj.data.player)
	end

	--- Process the keys and combos.
	function Controller:keysCheck()
		local combo_len = #self.hit_code
		local i = 0
		for key in pairs(self.key_timer) do
			i = i + 1
			if self:hit(key) then self.hit_code = self.hit_code .. i end
		end

		local new_combo_len = #self.hit_code
		if new_combo_len > combo_len then
			self.hit_timer = control.combination_timer
			if new_combo_len > control.max_combo then
				self.hit_code = self.hit_code:sub(1 + new_combo_len - combo_len)
			end
		end
	end

return Controller