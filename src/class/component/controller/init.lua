--- Controller component
-- @classmod l2df.class.component.controller
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Controller works only with l2df v1.0 and higher')

local pairs = _G.pairs

local Component = core.import 'class.component'
local InputManager = core.import 'manager.input'

local Controller = Component:extend()

	--- Component added to l2df.class.entity
	-- @param l2df.class.entity obj
	-- @param number player
	-- @return boolean
	function Controller:added(obj, player)
		if not obj then return false end
		obj.C.controller = self:wrap(obj)
		local data = obj.data
		data.player = player or data.player or 0
		-- TODO: add FSM for combos?
		return true
	end

	---
	-- @param l2df.class.entity obj
	function Controller:removed(obj)
		obj.C.controller = nil
	end

	--- Check if button was pressed
	-- @param l2df.class.entity obj
	-- @param string button  Pressed button
	-- @return boolean
	function Controller:pressed(obj, button)
		return InputManager:pressed(button, obj.data.player)
	end

	--- Check if button was double pressed
	-- @param l2df.class.entity obj
	-- @param string button  Double pressed button
	-- @return boolean
	function Controller:doubled(obj, button)
		return InputManager:doubled(button, obj.data.player)
	end

	--- Check if button was pressed at current frame
	-- @param l2df.class.entity obj
	-- @param string button  Hitted button
	-- @return boolean
	function Controller:hitted(obj, button)
		return InputManager:hitted(button, obj.data.player)
	end

	--- Process the keys and combos
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