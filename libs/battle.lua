function BattleProcessing()

	ControlCheck() -- функция проверки управления для всех игроков
	objects_for_drawing = {} -- обнуление массива объектов на отрисовку

	local remove_list = {} -- список объектов для удаления
	local creating_list = {} -- список объектов для создания

	for en_id = 1, #entity_list do -- для каждого из объектов в игре
		
		if entity_list[en_id] ~= "nil" and entity_list[en_id] ~= nil then -- если объект существует

			local en = entity_list[en_id] -- получаем объект
			local frame = GetFrame(en) -- получаем фрейм объекта

			StatesCheck(en_id) -- проверка стейтов

			Gravity(en_id) -- гравитация
			Motion(en_id) -- передвижение объекта
			BordersCheck(en_id) -- проверка на пересечение границ карты
			CollaidersFind(en_id)

			local draw_object = { id = en_id, z = en.z }
			table.insert(objects_for_drawing, draw_object)


			if en.wait <= 0 then -- если вайт подошёл к концу, переходим в указанный кадр
				SetFrame(en, en.next_frame)
			else
				en.wait = en.wait - 1 * delta_time * 100
			end


		end
	end

	CollisionersProcessing()
	CollisionsProcessing()

	CameraBinding()

	-- RemoveProcessing(remove_list) -- функция удаления объектов, помеченых к удалению
end



function CreateProcessing ()


end



function RemoveProcessing (list) -- функция предназначена для единовременного удаления из памяти всех объектов, помеченных к удалению, а так же для сборки оставшегося после них мусора
-------------------------------------
	for object = 1, #list do
		RemoveEntity(list[object])
	end
	collectgarbage()
end



function Spawner()
	players.player1 = nil
	players.player2 = nil
	for char = 1, #loading_list.characters do
		local id = CreateEntity(loading_list.characters[char])
		local object = entity_list[id]
		local spawn = map.spawn_points[math.random(1, #map.spawn_points)]
		
		object.x = spawn.x + math.random(-spawn.rx, spawn.rx)
		object.y = spawn.y + math.random(-spawn.ry, spawn.ry)
		object.z = spawn.z + math.random(-spawn.rz, spawn.rz)

		if spawn.facing == 0 then
			if math.random(1,2) == 1 then
				object.facing = 1
			else
				object.facing = -1
			end
		elseif (spawn.facing == -1) or (spawn.facing == 1) then
			object.facing = spawn.facing
		end

		for key, val in pairs(players_flags) do
			if (players_flags[key] == true) and (players[key] == nil) then
				players[key] = id
				break
			end
		end
	end
end