local state = { variables = {} } -- | 0 | -- Стойка
-- Персонаж находится в состоянии покоя. Ожидает действий игрока.
--		✶*		Ходьба
--		⇄+		Бег
--		A		Боевая стойка
--		J		Подготовка к прыжку
--		D		Защитная стойка
-- При длительном нахождении в состоянии покоя, персонаж переходит в кадры "анимации".
---------------------------------------------------------------------
function state:Processing(object,s)
	if object:timer("attack") then object:setFrame("battle_stance") end
	if object:timer("jump") then object:setFrame("jump_preparing") end
	if object:pressed("defend") and object.block_timer == 0 then object:setFrame("defend_stance") end
	--if object:timer("special1") then object:setFrame("special") end
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