function BattleProcessing() -- данная функция отвечает за обработку каждого тика в бою, включая в себя функции по обработке персонажей, гравитации, коллизий и так далее
-------------------------------------

	objects_for_drawing = {} -- обнуление массива объектов на отрисовку
	objects = 0 -- отладочная переменная количества объектов

	ControlCheck() -- функция проверки управления для всех игроков

	for en_id in pairs(entity_list) do -- для каждого из объектов в игре
		
		if entity_list[en_id] ~= nil then -- если объект существует

			objects = objects + 1 -- для вывода реального количества объектов в отладочной информации

			local en = entity_list[en_id] -- получаем объект

			HitCheck(en_id) -- проверка нажатий клавиш
			Accelerations(en_id) -- проверка ускорений
			StatesCheck(en_id) -- проверка стейтов

			Gravity(en_id) -- гравитация
			Motion(en_id) -- передвижение объекта
			BordersCheck(en_id) -- проверка на пересечение границ карты

			
			CollaidersFind(en_id) -- поиск коллайдеров

			if en.first_tick_flag then
				OpointProcessing(en_id)
				en.first_tick_flag = false
			end -- обработка opoint блоков

			local draw_object = { id = en_id, z = en.z } -- получение приоритета отрисовки
			table.insert(objects_for_drawing, draw_object) -- отправка объекта в список на отрисовку



			Time(en_id) -- обработка всего что связано со временем

			if en.destroy_flag == true then
				RemoveEntity(en_id)
			end -- уничтожение объекта
		end
	end

	CollisionersProcessing() -- поиск столкновений
	CollisionsProcessing() -- обработка столкновений
	CameraBinding() -- привязка камеры

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

		if map.start_anim then
			if object.starting_frame ~= 0 then
				SetFrame(object, object.starting_frame)
			elseif object.idle_frame ~= 0 then
				SetFrame(object, object.idle_frame)
			else
				SetFrame(object, 0)
			end
		end

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

		object.script.load(object)
	end
end


function Time(en_id) -- функция отвечает за обработку всех таймеров персонажа
-------------------------------------

	local en = entity_list[en_id]

	if en.arest > 0 then
		en.arest = en.arest - 1
	end -- сброс arest'a

	if en.vrest > 0 then
		en.vrest = en.vrest - 1
	end -- сброс vrest'a

	if en.defend < en.max_defend then
		if en.defend_timer <= 0 then
			en.defend_timer = 0
			en.defend = en.max_defend
		else
			en.defend_timer = en.defend_timer - 1
		end
	end -- восстановление брони

	if en.fall < en.max_fall then
		if en.fall_timer <= 0 then
			en.fall_timer = 0
			en.fall = en.max_fall
		else
			en.fall_timer = en.fall_timer - 1
		end
	end -- восстановление стойкости

	if en.wait <= 0 then
		SetFrame(en, en.next_frame)
	else
		en.wait = en.wait - 1 * delta_time * 100
	end -- изменение wait и смена кадров
	
end