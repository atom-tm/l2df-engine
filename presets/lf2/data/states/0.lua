--- Standing / Idle
local rnd = data.random

return function (obj, data)
	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	data.jspeedx = nil
	data.jspeedz = nil
	local up = control.pressed('up')
	local down = control.pressed('down')
	local left = control.pressed('left')
	local right = control.pressed('right')
	local adata = attr.data()
	if data.isjumped and control.pressed('jump') then
		data.jspeedx = adata.dash_distance
		data.jspeedz = up ~= down and adata.dash_distancez
		frames.set('dash')
	elseif (data.hit_j or 0) == 0 and control.hitted('jump') then
		frames.set('jump') -- jump / 210
	elseif adata.defence > 0 and (data.hit_d or 0) == 0 and control.hitted('defend') then
		frames.set('defend') -- defend / 110
	elseif (data.hit_a or 0) == 0 and control.hitted('attack') then
		frames.set(adata.cansuper and 'super_punch' or rnd(2) == 1 and 60 or 65) -- punch / 60 / 65
	elseif up == down and left == right then
		--data.vx, data.vz = 0, 0
	else
		data.facing = left and -1 or right and 1 or data.facing
		if control.doubled('left') or control.doubled('right') then
			frames.set('running')
		else
			frames.set('walking')
		end
	end
	data.isjumped = nil
	data.isdashed = nil
end