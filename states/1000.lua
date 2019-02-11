local state = { variables = {} } -- | 1000 | --  Удаление объекта
-- 
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.wait <= 0 then
		object.destroy = true
	end
end

return state