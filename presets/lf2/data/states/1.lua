--- Walking
local rnd = data.random

return function (obj, data)
	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	local adata = attr.data()
	local def = (data.hit_d or 0) == 0 and control.hitted('defend')
	local jmp = (data.hit_j or 0) == 0 and control.hitted('jump')
	local atk = (data.hit_a or 0) == 0 and control.hitted('attack')
	local speedx = adata.walking_speed
	local speedz = adata.walking_speedz
	if speedx then
		local left = control.pressed('left')
		local right = control.pressed('right')
		if left ~= right then
			data.dvx = speedx
			data.facing = left and -1 or 1
		end
	end
	local up = control.pressed('up')
	local down = control.pressed('down')
	if speedz then
		if up then
			data.dvz = data.dvz - speedz
		end
		if down then
			data.dvz = data.dvz + speedz
		end
	end

	if adata.defence > 0 and def then
		frames.set('defend') -- defend / 110
	elseif jmp then
		data.jspeedx = adata.jump_distance
		data.jspeedz = up ~= down and adata.jump_distancez
		frames.set('jump') -- jump / 210
	elseif atk then
		frames.set(adata.cansuper and 'super_punch' or rnd(2) == 1 and 60 or 65) -- punch / 60 / 65
	elseif data.dvz == 0 and data.dvx == 0 then
		frames.set('standing')
	else
		data.next = (data.frame.id - 4) % (adata.walking_frame_rate + 1) + 5
	end
end