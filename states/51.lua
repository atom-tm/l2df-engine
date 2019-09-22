local state = { variables = {} } -- | 50 | -- Таймер с переходом в кадр
-- 
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.wait == 0 then
		object:setFrame(object.previous_frame)
	end
end

return state