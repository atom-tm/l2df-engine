local state = { variables = {} } -- | 1001 | --  Установка слоя отрисовки
-- 
---------------------------------------------------------------------
function state:Processing(object,s)
	if s.index ~= nil then
		object.index = s.index
	end
end

return state