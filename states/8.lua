local state = { variables = {} } -- | 8 | -- Лежание
-- Задает объекту статус "лежит"
---------------------------------------------------------------------
function state:Update(object)
	if state.variables.lying_status then
		state.variables.lying_status = false
	else object.lying = false end
end
---------------------------------------------------------------------
function state:Processing(object,s)
	state.variables.lying_status = true
	object.lying = true
end

return state