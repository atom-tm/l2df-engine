local state = { variables = {} } -- | 5 | -- Стойка в воздухе
--Персонаж находится в воздухе в состоянии свободного падения. При достижении земли, переходит в кадры "приземления", обнуляя скорость по оси Y.
-- A	Атака в воздухе
-- S↓*	Рывок вниз
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.grounded then
		object:setFrame("landing")
	else
		if object:timer("attack") then object:setFrame("air_attack")
		elseif object:timer("special1") and object:pressed("down") then object:setFrame("shunshin_down") end
	end
end
return state