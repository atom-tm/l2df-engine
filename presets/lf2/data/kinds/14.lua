local kind = {}

	function kind:Start(attacker, itr, defender, body)
		local x1 = attacker.x - attacker.frame.centerx * attacker.facing + itr.x * attacker.facing
		local x2 = x1 + itr.w * attacker.facing
		local x_center_of_itr = (x1 + x2) / 2

		local z1 = attacker.z + itr.z
		local z2 = z1 + itr.l
		local z_center_of_itr = (z1 + z2) / 2

		local bz1 = defender.z + body.z
		local bz2 = bz1 + body.l
		local z_center_of_body = (bz1 + bz2) / 2

		local bx1 = defender.x - defender.frame.centerx * defender.facing + body.x * defender.facing
		local bx2 = bx1 + body.w * defender.facing
		local x_center_of_body = (bx1 + bx2) / 2

		if defender.x < x_center_of_itr and defender.vel_x > 0 then
			defender:setMotion_X(0)
			defender.x = helper.min(x1,x2) + (defender.x - helper.max(bx1,bx2))
		elseif defender.x >= x_center_of_itr and defender.vel_x < 0 then
			defender:setMotion_X(0)
			defender.x = helper.max(x1,x2) + (defender.x - helper.min(bx1,bx2))
		--[[elseif z_center_of_body < z_center_of_itr and defender.vel_z > 0 then
			defender:setMotion_Z(0)
			defender.z = helper.min(z1,z2) + (defender.z - helper.max(bz1,bz2))
		elseif z_center_of_body >= z_center_of_itr and defender.vel_z < 0 then
			defender:setMotion_Z(0)
			defender.z = helper.max(z1,z2) + (defender.z - helper.min(bz1,bz2))]]
		else
			if defender.x < x_center_of_itr then
				defender.x = helper.min(x1,x2) + (defender.x - helper.max(bx1,bx2))
			elseif defender.x >= x_center_of_itr then
				defender.x = helper.max(x1,x2) + (defender.x - helper.min(bx1,bx2))
			end
		end
	end

return kind