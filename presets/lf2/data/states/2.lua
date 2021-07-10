return function (obj, data)
	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	local jmp = control.hitted('jump')
	local speedx = attr.data().running_speed + (jmp and attr.data().dash_distance or 0)
	local speedz = attr.data().running_speedz + (jmp and attr.data().dash_distancez or 0)
	if speedx then
		data.dvx = data.dvx + speedx * data.facing
	end
	if speedz then
		if control.pressed('up') then
			data.dvz = data.dvz - speedz
		end
		if control.pressed('down') then
			data.dvz = data.dvz + speedz
		end
	end

	if data.dvz == 0 then data.vz = 0 end

	if
		data.facing == 1 and control.pressed('left') or
		data.facing == -1 and control.pressed('right')
	then
		frames.set('stop_running')
	elseif jmp then
		frames.set(213) -- dash
	else
		data.frame.next = (data.frame.id - 8) % 3 + 9
	end
end