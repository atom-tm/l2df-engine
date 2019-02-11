local kind = {}

function kind:Start(attacker, itr, damaged, body)

	local x1 = (attacker.x - attacker.frame.centerx * attacker.facing + itr.x * attacker.facing)
	local x2 = x1 + itr.w * attacker.facing
	local x_center_of_itr = (x1 + x2) / 2

	local z1 = attacker.z + itr.z
	local z2 = z1 + itr.l
	local z_center_of_itr = (z1 + z2) / 2

	local bz1 = damaged.z + body.z
	local bz2 = bz1 + body.l
	local z_center_of_body = (bz1 + bz2) / 2

	local bx1 = (damaged.x - damaged.frame.centerx * damaged.facing + body.x * damaged.facing)
	local bx2 = bx1 + body.w * damaged.facing
	local x_center_of_body = (bx1 + bx2) / 2

	if damaged.x < x_center_of_itr and damaged.vel_x > 0 then
		damaged:setMotion_X(0)
		damaged.x = get.Least(x1,x2) + (damaged.x - get.Biggest(bx1,bx2))
	elseif damaged.x >= x_center_of_itr and damaged.vel_x < 0 then
		damaged:setMotion_X(0)
		damaged.x = get.Biggest(x1,x2) + (damaged.x - get.Least(bx1,bx2))
	--[[elseif z_center_of_body < z_center_of_itr and damaged.vel_z > 0 then
		damaged:setMotion_Z(0)
		damaged.z = get.Least(z1,z2) + (damaged.z - get.Biggest(bz1,bz2))
	elseif z_center_of_body >= z_center_of_itr and damaged.vel_z < 0 then
		damaged:setMotion_Z(0)
		damaged.z = get.Biggest(z1,z2) + (damaged.z - get.Least(bz1,bz2))]]
	else
		if damaged.x < x_center_of_itr then
			damaged.x = get.Least(x1,x2) + (damaged.x - get.Biggest(bx1,bx2))
		elseif damaged.x >= x_center_of_itr then
			damaged.x = get.Biggest(x1,x2) + (damaged.x - get.Least(bx1,bx2))
		end
	end
	
end

return kind