return function (obj, data, params)
	if data.next == 999 then
		if 5 <= data.frame.id and data.frame.id <= 8 then
			data.next = (data.frame.id - 4) % 4 + 5
		else
			data.next = 0
		end
	end
	if data.pic then
		data.pic = data.pic + 1
	end
	if data.bodies then
		for i = 1, #data.bodies do
			if not data.bodies[i].___modified then
				data.bodies[i].x = data.bodies[i].x - (data.centerx or 0)
				data.bodies[i].y = data.bodies[i].y - (data.centery or 0)
				data.bodies[i].___modified = true
			end
		end
	end
	if data.itrs then
		for i = 1, #data.itrs do
			if not data.itrs[i].___modified then
				data.itrs[i].x = data.itrs[i].x - (data.centerx or 0)
				data.itrs[i].y = data.itrs[i].y - (data.centery or 0)
				data.itrs[i].___modified = true
			end
		end
	end
end