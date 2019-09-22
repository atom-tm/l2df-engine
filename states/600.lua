local state = { variables = {} } -- | 600 | -- Частица
-- 
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.wait == 0 then
		if s.dvx ~= nil then
			if math.random(0,100) <= s.dvx then
				object:setMotion_X(-object.vel_x)
			end
		end
		if s.retry ~= nil then
			if math.random(0,100) <= s.retry then
				if s.frame ~= nil then
					object:setFrame(s.frame)
				else
					object.wait = object.frame.wait
				end
			end
		end
	end
end

return state