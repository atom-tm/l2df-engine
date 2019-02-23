local state = { variables = {} } -- | 0 | -- Стойка
-- Стойка, положение покоя персонажа
-- При нажатии "Атака\\Прыжок\\Защита" объект переходит в соответсвующие кадры
-- При нажатии клавиш перемещения объект переходит в кадры ходьбы, а при двойном нажатии в кадры бега
---------------------------------------------------------------------
function state:Processing(object,s)
	if object:timer("attack") then object:setFrame("attack") end
	if object:timer("jump") then object:setFrame("jump") end
	if object:pressed("defend") and object.block_timer == 0 then object:setFrame("defend") end
	if object:timer("special1") then object:setFrame("special") end
	
	if object:double_timer("left") or object:double_timer("right") then
		if object:double_timer("left") then object.facing = -1 end
		if object:double_timer("right") then object.facing = 1 end
		object:setFrame("running", object.running_frame)
	end
	if (object:pressed("up") or object:pressed("down") or object:pressed("left") or object:pressed("right")) and object.wait == 0 then
		if object:pressed("left") then object.facing = -1 end
		if object:pressed("right") then object.facing = 1 end
		object:setFrame("walking", object.walking_frame)
	end
end

return state