local state = { variables = {} } -- | 13 | -- Падение
-- 
---------------------------------------------------------------------
function state:Processing(object,s)
	object.gravity = true
	if object.old_vel_y <= 0 and object.grounded then
		if object.old_vel_y < -20 and s.repulse then
			object:setFrame(s.repulse)
			object:setMotion_Y(-object.old_vel_y * 0.5)
		else
			if s.grounded then object:setFrame(s.grounded)
			else object:setFrame("lying") end
		end
	else
		if object.wait == 0 and object.frame.next == 0 then
			if object.vel_y > 0 and s.up then
				object:setFrame(s.up)
			elseif object.vel_y <= 0 and s.down then
				object:setFrame(s.down)
			else
				object:setFrame(object.frame.number)
			end
		end
	end
end

return state