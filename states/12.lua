local state = { variables = {} } -- | 12 | -- Атака
-- 
---------------------------------------------------------------------
function state:Processing(object,s)
	if object:timer("attack") then
		if s.up and object:pressed("up") then object.next_frame = s.up
		elseif s.down and object:pressed("down") then object.next_frame = s.down
		elseif s.attack then object.next_frame = s.attack end
	end
	if s.turn == true then
		if object:pressed("left") then object.facing = -1 end
		if object:pressed("right") then object.facing = 1 end
	end
end

return state