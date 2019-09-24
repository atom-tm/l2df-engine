local state = { variables = {} } -- | 550 | -- Остановка
-- Полное обнуление скоростей по выбранным осям
---------------------------------------------------------------------
function state:Processing(object,s)
	if s.x then object:setMotion_X(0) end
	if s.y then object:setMotion_Y(0) end
	if s.z then object:setMotion_Z(0) end
end

return state