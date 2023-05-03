return function (obj, data)
	local control = obj.C.controller
	local frames = obj.C.frames
	if control and frames then
		if (data.hit_d or 0) ~= 0 and control.hitted('defend') then
			frames.set(data.hit_d)
		elseif (data.hit_j or 0) ~= 0 and control.hitted('jump') then
			frames.set(data.hit_j)
		elseif (data.hit_a or 0) ~= 0 and control.hitted('attack') then
			frames.set(data.hit_a)
		end
	end
	local factor = 1 / l2df:convert(1)
	if data.dvx == 550 then
		data.dvx = 0
		data.vx = 0
	end
	if data.dvy == 550 then
		data.dvy = 0
		data.vy = 0
	end
	if data.dvz == 550 then
		data.dvz = 0
		data.vz = 0
	end
	if data.dvx then
		data.dvx = data.dvx * data.facing * factor
	end
	if data.dvz then
		data.dvz = data.dvz * factor
	end
	if data.next == 999 then
		data.next = 0
	end
	if data.pic then
		data.pic = data.pic + 1
	end
	if data.bodies then
		for i = 1, #data.bodies do
			local body = data.bodies[i]
			if not body.___modified then
				body.x = body.x - (data.centerx or 0)
				body.y = body.y - (data.centery or 0)
				body.d = 2
				body.___modified = true
			end
		end
	end
	if data.itrs then
		for i = 1, #data.itrs do
			local itr = data.itrs[i]
			if not itr.___modified then
				itr.x = itr.x - (data.centerx or 0)
				itr.y = itr.y - (data.centery or 0)
				itr.z = -15
				itr.d = 32
				if itr.dvx then
					itr.dvx = itr.dvx * factor
				end
				if itr.dvy then
					itr.dvy = itr.dvy * factor
				end
				itr.___modified = true
			end
		end
	end
end