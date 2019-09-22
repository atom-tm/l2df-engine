local state = { variables = {} } -- | 6 | -- Приземление
--Персонаж находится в состоянии отката после прыжка.
-- S→*	Рывок вперед
-- S←*	Рывок назад
-- A	Сильная атака
---------------------------------------------------------------------
function state:Processing(object,s)
	if object:timer("special1") and ((object:pressed("left") and object.facing == -1) or (object:pressed("right") and object.facing == 1)) then object:setFrame("shunshin_forward")
	elseif object:timer("special1") and ((object:pressed("left") and object.facing == 1) or (object:pressed("right") and object.facing == -1)) then object:setFrame("shunshin_back") end
end
return state