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
	battle.graphic:addLightSource(object.x, object.y + 15,object.z, 175, 0.7, true)
	battle.graphic:addLightSource(object.x - 90, object.y + 15,object.z, 175, 0.7, false)
	battle.graphic:addLightSource(object.x + 90, object.y + 15,object.z, 175, 0.7, false)
end
return state