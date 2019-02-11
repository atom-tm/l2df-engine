local kind = {}

function kind:Start(attacker, itr, damaged, body)
	if (itr.purpose == 1 and ((attacker.team ~= damaged.team) or attacker.team == -1 or damaged.team == -1) and attacker.owner ~= damaged.owner)
	or (itr.purpose == 0)
	or (itr.purpose == -1 and (attacker.team == damaged.team) and (attacker.team ~= -1 or damaged.team ~= -1)) then
		if itr.attacker_frame ~= 0 then attacker:setFrame(itr.attacker_frame) end
		if itr.damaged_frame ~= 0 then damaged:setFrame(itr.damaged_frame) end
	end
end

return kind