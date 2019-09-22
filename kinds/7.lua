local kind = {}

function kind:Start(attacker, itr, damaged, body)
	if (itr.purpose == 1 and ((attacker.team ~= damaged.team) or attacker.team == -1 or damaged.team == -1) and attacker.owner ~= damaged.owner)
	or (body.participle)
	or (itr.purpose == 0)
	or (itr.purpose == -1 and (attacker.team == damaged.team) and (attacker.team ~= -1 or damaged.team ~= -1)) then
		
		if not body.static then
			damaged:setMotion_X(attacker.vel_x)
			damaged:setMotion_Y(attacker.vel_y)
			damaged:setMotion_Z(attacker.vel_z)
		end
	end
end

return kind