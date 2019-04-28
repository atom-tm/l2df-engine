local kind = {}

function kind:Start(attacker, itr, defender, body)
	if (itr.purpose == 1 and ((attacker.team ~= defender.team) or attacker.team == -1 or defender.team == -1) and attacker.owner ~= defender.owner)
	or (body.participle)
	or (itr.purpose == 0)
	or (itr.purpose == -1 and (attacker.team == defender.team) and (attacker.team ~= -1 or defender.team ~= -1)) then

		if itr.attacker_frame ~= 0 then attacker:setFrame(itr.attacker_frame) end
		if itr.defender_frame ~= 0 then defender:setFrame(itr.defender_frame) end
		
	end
end

return kind