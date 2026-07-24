--- Solid 3D Object
return function (e1, e2, itr, bdy)
	if not (e1 and e2 and itr and bdy and itr.owner == e1 and bdy.owner == e2) then
		return false
	end
	if e1 == e2 then
		return false
	end
	local dx = (e2.data.x or 0) - (e1.data.x or 0)
	local dz = (e2.data.z or 0) - (e1.data.z or 0)
	if math.abs(dx) >= math.abs(dz) then
		e2.data.x = (e2.data.x or 0) + (dx < 0 and -1 or 1)
		e2.data.dx, e2.data.vx = 0, 0
	else
		e2.data.z = (e2.data.z or 0) + (dz < 0 and -1 or 1)
		e2.data.dz, e2.data.vz = 0, 0
	end
	return true
end
