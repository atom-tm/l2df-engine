--- Falling
return function (obj, data)
	local frames, control, sound = obj.C.frames, obj.C.controller, obj.C.sound
	if not (control and frames and sound) then return end

	local vy = data.vy
	local frame = data.frame.id
	local rshift = frame < 186 and 0 or 6
	local jmp = (data.hit_j or 0) == 0 and control.hitted('jump')
	-- TODO: drop weapon
	-- TODO: immune to any attack that has less than 41 fall
	if data.ground then
		if frame < 184 + rshift then
			frame = 184 + rshift -- falling
			frames.set(frame)
			sound.play('drop')
		elseif frame == 185 + rshift then
			sound.play('bounce')
			data.dvx = l2df:convert(2) * (rshift == 0 and -1 or 1)
			data.next = 230 + (rshift == 0 and 0 or 1) -- lying
			return
		end
		data.wait = 0
		data.next = frame + 1
	elseif jmp and frame == 182 + rshift then
		data.flip = frame == 182 and -1 or 1
		frames.set(frame == 182 and 100 or 108) -- backflip / rowing
	elseif vy > 10 * 30 then
		frames.set(180 + rshift) -- falling
	elseif vy > 0 then
		frames.set(181 + rshift) -- falling
	elseif vy > -6 * 30 then
		frames.set(182 + rshift) -- falling
	else
		frames.set(183 + rshift) -- falling
	end
end