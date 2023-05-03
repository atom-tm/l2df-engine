--- Normal hit
return function (e1, e2, itr, bdy)
	if itr.owner == bdy.owner then
		return
	end
	if bdy.owner == e1 then
		return
	end
	local frames, attr, sound = e2.C.frames, e2.C.attr, e2.C.sound
	local looks_in_same_direction = e1.data.facing == e2.data.facing
	if attr and attr.damage(itr.col, looks_in_same_direction) then -- not e1.data.stunned and
		local pain = attr.data().pain
		if pain < 0 then
			frames.set(looks_in_same_direction and 186 or 180) -- falling
			e2.data.dvy = l2df:convert(2)
		elseif pain == 0 then
			frames.set(226) -- injured / dance of pain
		elseif pain <= 20 then
			frames.set(looks_in_same_direction and 224 or 222) -- injured2
		else
			frames.set(220) -- injured1
		end
		if sound then
			sound.play(pain < 0 and 'super_punch' or 'punch', true)
		end
		if itr.dvx then e2.data.dvx = itr.dvx * e1.data.facing end
		if itr.dvy then e2.data.dvy = -itr.dvy end
	elseif e2.data.frame.id == 110 then -- defend
		frames.set(111) -- defend
		if sound then
			sound.play('block')
		end
	end
end