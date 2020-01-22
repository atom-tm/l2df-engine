--- Controller component
-- @classmod l2df.class.component.controller
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Controller works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local Controller = Component:extend({ unique = true })

	--- Check if button is pressed
	-- @param string button  Pressed button
	-- @return boolean
	function Controller:pressed(button)
		return false
	end

    function Controller:added(entity, player)
        if not entity then return false end

        self.entity = entity
        local vars = entity.vars
        vars.player = player or vars.player or 0
        -- TODO: add FSM for combos?
        return true
    end

	--- Check if button's timer is executed
	-- @param string button  Pressed button
	-- @return boolean
	function Controller:timer(button)
		return self.key_timer[button] > 0
	end

	--- Check if button's double_timer is executed
	-- @param string button  Pressed button
	-- @return boolean
	function Controller:double_timer(button)
		return self.double_key_timer[button] > 0
	end

	--- Check if button's double_timer is ended
	-- @param string button  Pressed button
	-- @return boolean
	function Controller:hit(button)
		return self.key_timer[button] == control.key_timer
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