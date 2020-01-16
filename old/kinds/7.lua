local kind = {}

	function kind:Start(attacker, itr, defender, body)
		if itr.purpose == 1 and (attacker.team ~= defender.team or attacker.team == -1 or defender.team == -1) and attacker.owner ~= defender.owner
		or body.participle
		or itr.purpose == 0
		or itr.purpose == -1 and attacker.team == defender.team and (attacker.team ~= -1 or defender.team ~= -1) then

			if not body.static then
				defender:setMotion_X(attacker.vel_x)
				defender:setMotion_Y(attacker.vel_y)
				defender:setMotion_Z(attacker.vel_z)
			end
		end
	end

return kind