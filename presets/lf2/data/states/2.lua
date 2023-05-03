--- Running
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
	if speedx then
		data.dvx = speedx
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

	if data.dvz == 0 then data.vz = 0 end

	if
		data.facing == 1 and control.pressed('left') or
		data.facing == -1 and control.pressed('right')
	then
		frames.set('stop_running')
	elseif def then
		frames.set('rowing') -- rolling / rowing / 102
	elseif jmp then
		data.jspeedx = adata.dash_distance
		data.jspeedz = up ~= down and adata.dash_distancez
		frames.set('dash') -- dash / 213
	elseif atk then
		frames.set('run_attack') -- run_attack / 85
	elseif data.frame.id ~= 2012 then
		local n = (data.frame.id - 8) % adata.running_frame_rate + 9
		data.frame.next = n == 12 and 2012 or n
	end
end