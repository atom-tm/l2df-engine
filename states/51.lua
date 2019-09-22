local state = { variables = {} } -- | 51 | -- 
-- 
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.wait == 0 then
		object:setFrame(object.previous_frame)
	end
end

return state