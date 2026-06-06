--- Running
-- If a player presses left or right two times quickly, the character will run.
-- State 2 is used for the running frames, and running_speed and running_speedz sets the speed.
-- If you press J while running, your character go to dash.
-- While pressing A and he'll go to run_attack.
-- Pressing D will cause the character to jump to rowing.
local frame = require 'data.scripts.frame'

return function (obj, data)
	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	local adata = attr.data()
	local def = (data.hit_d or 0) == 0 and control.hitted('defend')
	local jmp = (data.hit_j or 0) == 0 and control.hitted('jump')
	local atk = (data.hit_a or 0) == 0 and control.hitted('attack')
	local speedx = adata.running_speed
	local speedz = adata.running_speedz
	if speedx then data.dvx = speedx end
	local up = control.pressed('up')
	local down = control.pressed('down')
	if speedz then
		if up then data.dvz = data.dvz - speedz end
		if down then data.dvz = data.dvz + speedz end
	end
	if data.dvz == 0 then data.vz = 0 end

	if data.facing == 1 and control.pressed('left') or data.facing == -1 and control.pressed('right') then
		frame.set(obj, 'stop_running', true)
	elseif def then
		frame.set(obj, 102, true)
	elseif jmp then
		data.jspeedx = adata.dash_distance
		data.jspeedz = up ~= down and adata.dash_distancez * (up and -1 or 1)
		frame.set(obj, 213, true)
	elseif atk then
		local left = control.pressed('left')
		local right = control.pressed('right')
		if data._lf2_weapon then
			if data._lf2_weapon_run_used or left or right then
				data._lf2_weapon = nil
				data._lf2_weapon_run_used = nil
				frame.set(obj, 45, true)
			else
				data._lf2_weapon_run_used = true
				frame.set(obj, 35, true)
			end
		else
			frame.set(obj, 'run_attack', true)
		end
	elseif data.frame.id ~= 2012 then
		local n = (data.frame.id - 8) % adata.running_frame_rate + 9
		data.frame.next = n == 12 and 2012 or n
	end
end
