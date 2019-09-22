local state = { variables = {} } -- | 3 | -- Подготовка к прыжку
-- Персонаж приседает и готовится к прыжку.
--	→*	Прыжок вперед
--	←*	Прыжок назад
--	S	Рывок вверх
--	S→*	Рывок вверх и вперед
--	S←*	Рывок вверх и назад
--Если клавиши не нажимаются и не удерживаются, просиходит обычный "прыжок" вверх.
---------------------------------------------------------------------
function state:Processing(object,s)
	if object:timer("special1") then
		if (object:pressed("left") and object.facing == -1) or (object:pressed("right") and object.facing == 1) then
			object:setFrame("shunshin_up_forward")
		elseif (object:pressed("left") and object.facing == 1) or (object:pressed("right") and object.facing == -1) then
			object:setFrame("shunshin_up_back")
		else
			object:setFrame("shunshin_up")
		end
	elseif object.wait == 0 then
		if (object:pressed("left") and object.facing == -1) or (object:pressed("right") and object.facing == 1) then
			object:setFrame("jump_forward")
		elseif (object:pressed("left") and object.facing == 1) or (object:pressed("right") and object.facing == -1) then
			object:setFrame("jump_back")
		else
			object:setFrame("jump_up")
		end
	end
end

return state