local state = {}
	local c = battle.control
	local e = battle.entities
	function state:Start(object,frame,state,map)
		if (c.pressed(object,"right") and object.facing == -1) or (c.pressed(object,"left") and object.facing == 1) then 
			if state.frame ~= nil then
				object.next_frame = state.frame
			end
		end
	end
return state