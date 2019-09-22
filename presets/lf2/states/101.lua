local state = { variables = {} } -- | 101 | -- Эффект Следования
-- Создает эффект трения, из списка эффектов карты, при определенных условиях
---------------------------------------------------------------------
function state:Update(object)
	if object.target then
		object.x = object.x + object.target.vel_x * math.random(70,90) * 0.01
	end
end

return state