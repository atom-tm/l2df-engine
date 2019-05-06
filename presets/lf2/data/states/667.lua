local state = { variables = {} } -- | 667 | -- Телепорты к врагам
-- Телепортирует объект к врагу по заданному типу на заданное расстояние
-- TYPES:
--  1 - Ближайший враг
--  2 - Дальний враг
--  3 - Средний враг
--  4 - Случайный враг
---------------------------------------------------------------------
function state:Processing(object,s)
	if s.type then
		local distances_list = {}
		for i = 1, #battle.chars do
			local char = battle.chars[i]
			if entities.isEnemy(object,char) then
				local dist = math.sqrt((object.x - char.x)^2 + (object.y - char.y)^2 + (object.z - char.z)^2)
				local temp = {
					character = char,
					distance = dist
				}
				table.insert(distances_list,temp)
			end
		end
	end
end

return state