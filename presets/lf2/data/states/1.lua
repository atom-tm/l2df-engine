return function (obj, data)
	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	local jmp = control.hitted('jump')
	local speedx = attr.data().walking_speed + (jmp and attr.data().jump_distance or 0)
	local speedz = attr.data().walking_speedz + (jmp and attr.data().jump_distancez or 0)
	if speedx then
		if control.pressed('left') then
			data.dvx = data.dvx - speedx
			data.facing = -1
		end
		if control.pressed('right') then
			data.dvx = data.dvx + speedx
			data.facing = 1
		end
	end
	if speedz then
		if control.pressed('up') then
			data.dvz = data.dvz - speedz
		end
		if control.pressed('down') then
			data.dvz = data.dvz + speedz
		end
	end

	if data.dvx == 0 then data.vx = 0 end
	if data.dvz == 0 then data.vz = 0 end

	if jmp then
		frames.set(210) -- jump
	elseif data.vz == 0 and data.vx == 0 then
		frames.set('standing')
	end
end