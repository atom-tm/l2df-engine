local state = { variables = {} } -- | 500 | -- Техника
-- Стейт для реализации механики ручных печатей
---------------------------------------------------------------------
function state:Processing(object,s)

	if s.rx1 ~= nil and s.rx2 ~= nil then
		object:addMotion_X(math.random(s.rx1 * 100, s.rx2 * 100) * object.facing * 0.01)
	elseif s.rx1 ~= nil then
		object:addMotion_X(math.random(0, s.rx1 * 100) * object.facing * 0.01)
	elseif s.rx2 ~= nil then
		object:addMotion_X(math.random(0, s.rx2 * 100) * object.facing * 0.01)
	end

	if s.ry1 ~= nil and s.ry2 ~= nil then
		object:addMotion_Y(math.random(s.ry1 * 100, s.ry2 * 100) * 0.01)
	elseif s.ry1 ~= nil then
		object:addMotion_Y(math.random(0, s.ry1 * 100) * 0.01)
	elseif s.ry2 ~= nil then
		object:addMotion_Y(math.random(0, s.ry2 * 100) * 0.01)
	end

	if s.rz1 ~= nil and s.rz2 ~= nil then
		object:addMotion_Z(math.random(s.rz1 * 100, s.rz2 * 100) * 0.01)
	elseif s.rz1 ~= nil then
		object:addMotion_Z(math.random(0, s.rz1 * 100) * 0.01)
	elseif s.rz2 ~= nil then
		object:addMotion_Z(math.random(0, s.rz2 * 100) * 0.01)
	end
	
end

return state