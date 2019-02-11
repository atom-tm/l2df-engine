local state = { variables = {} } -- | 5 | -- Блок
-- Описание действия стейта и его переменных.
--
---------------------------------------------------------------------
function state:Update(object)
	if state.variables.block_status then
		state.variables.block_status = false
	else
		object.block = 0
	end
end
---------------------------------------------------------------------
function state:Processing(object,s)
	if object:pressed("defend") then
		if object.block <= 0 then
			object.block = s.block
		end
		state.variables.block_status = true
		object.block_timer = 40
		if object.wait == 0 then
			object.wait = object.wait + 1
		end
	end
end
---------------------------------------------------------------------
return state