local state = { variables = {} } -- | 11 | -- Поворот
-- Поворот объекта влево\\вправо при нажатии соответствующих клавиш
---------------------------------------------------------------------
function state:Processing(object,s)
	if object:pressed("up") then object:addMotion_Z(-s.accel) end
	if object:pressed("down") then object:addMotion_Z(s.accel) end
end

return state