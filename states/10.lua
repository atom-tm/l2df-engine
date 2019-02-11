local state = { variables = {} } -- | 10 | -- Поворот
-- Поворот объекта влево\\вправо при нажатии соответствующих клавиш
---------------------------------------------------------------------
function state:Processing(object,s)
	if object:pressed("left") then object.facing = -1 end
	if object:pressed("right") then object.facing = 1 end
end

return state