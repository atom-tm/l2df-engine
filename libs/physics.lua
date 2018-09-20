function collidersVerification(col1, col2) -- функция проверки двух коллайдеров на пересечение
---------------------------------------------------------------------

	local result = {
		collision = false,
		collision_center_x = "none",
		collision_center_y = "none",
		collision_direction_x = "undefined",
		collision_direction_y = "undefined",
		entity_id = nil,
		collider_id  = nil
	} -- переменная, которая будет возвращаться после выполнения функции сравнения

	local col1x1 = col1.x -- получение координаты x1 первого коллайдера
	local col1x2 = col1.x + col1.w -- получение координаты х2 первого коллайдера
	local col1y1 = col1.y -- получение координаты y1 первого коллайдера
	local col1y2 = col1.y + col1.h -- получение координаты y2 первого коллайдера
	
	local col2x1 = col2.x -- получение координаты x1 второго коллайдера
	local col2x2 = col2.x + col2.w -- получение координаты х2 второго коллайдера
	local col2y1 = col2.y -- получение координаты y1 второго коллайдера
	local col2y2 = col2.y + col2.h -- получение координаты y2 второго коллайдера

	if (((math.abs(col1x1 - col2x1) + math.abs(col1x2 - col2x2)) <= (col1.w + col2.w)) and ((math.abs(col1y1 - col2y1) + math.abs(col1y2 - col2y2)) <= (col1.h + col2.h))) then
	 	 
		result.collision = true -- говорим что пересечение есть

	 	if (col1x1 < col2x1) and (col1x2 < col2x2) then
	 	 	result.collision_direction_x = "left"
	 	elseif (col1x1 > col2x1) and (col1x2 > col2x2) then
	 	 	result.collision_direction_x = "right"
	 	else
	 		result.collision_direction_x = "center"
	 	end -- узнаем с какой стороны пересеклись по x

	 	if (col1y1 < col2y1) and (col1y2 < col2y2) then
	 	 	result.collision_direction_y = "top"
	 	elseif (col1y1 > col2y1) and (col1y2 > col2y2) then
	 	 	result.collision_direction_y = "bottom"
	 	else
	 	 	result.collision_direction_y = "center"
	 	end -- узнаем с какой стороны пересеклись по y
	 	 
	 	local xvalues = {col1x1, col1x2, col2x1, col2x2}
	 	local yvalues = {col1y1, col1y2, col2y1, col2y2}

	 	for i=1,4 do
	 	 	for j=1,4 do
	 	 		if xvalues[j] > xvalues[i] then
	 	 			local xv = xvalues[j]
	 	 			xvalues[j] = xvalues[i]
	 	 			xvalues[i] = xv
	 	 		end
	 	 		if yvalues[j] > yvalues[i] then
	 	 			local yv = yvalues[j]
	 	 			yvalues[j] = yvalues[i]
	 	 			yvalues[i] = yv
	 	 		end
	 	 	end
	 	end -- сортировка массивов для нахождения краёв "пересечения"

	 	result.collision_center_x = (xvalues[2] + xvalues[3]) / 2
	 	result.collision_center_y = (yvalues[2] + yvalues[3]) / 2
	 	--[ нахождение центров пересечения коллайдеров ]

	end
	return result -- возвращаем результат сравнения
end


function Gravity(en) -- отвечает за гравитацию, иннерцию и скорость персонажа по всем осям. функция не выполняет перемещение, а лишь высчитывает поведение скоростей исходя из всех факторов.
-------------------------------------
	if en.physic then
		en.in_air = false

		for key, val in ipairs(en.collisions) do
		end

		if en.in_air then 



		end
	end
end


function Motion(en_id, dt)
	en = entity_list[en_id]
	en.y = en.y + en.velocity_y
	en.x = en.x + en.velocity_x

	if (en.velocity_x ~= 0) or (en.velocity_y ~= 0) then
		--CheckCollisions(en_id)
	end
end




function CheckCollisions(en_id) -- для каждого коллайдера каждого загруженного объекта проверяет столкновения с другими коллайдерами и записывает информацию обо всех столкновениях в датку персонажа
-------------------------------------
	local en = entity_list[en_id] -- получаем объект
	local en_frame = GetFrame(en) -- получаем фрейм объекта
	en.collisions = {}

	local max_rad = en_frame.itr_radius + en_frame.body_radius +  en_frame.platform_radius

	if max_rad > 0 then
		for t_id = 1, #entity_list do -- для каждого объекта на карте
			if t_id ~= en_id then -- если проверяемый объект не является проверяющим объектом

				local target = entity_list[t_id] -- получает проверяемый объект
				local t_frame = GetFrame(target) -- получаем фрейм проверяемого объекта

				local distantion = math.sqrt(math.abs((en.x - target.x)^2) + math.abs((en.y - target.y)^2))

				if (en_frame.itr_radius > 0) and (t_frame.body_radius > 0) then
					if distantion < (en_frame.itr_radius + t_frame.body_radius) then
						for itr_id = 1, #en_frame.itrs do
							for body_id = 1, #t_frame.bodys do
								local itr = GetCollider(en_frame.itrs[itr_id], en)
								local body = GetCollider(t_frame.bodys[body_id], target)
								local result = collidersVerification(itr,body)
								if result.collision then
									local collision_entity = {
										target = t_id,
										itr = itr_id,
										body = body_id,
										info = result
									}
									table.insert(en.collisions, collision_entity)
								end
							end
						end
					end
				end

				if (en_frame.itr_radius > 0) and (t_frame.body_radius > 0) then
					if distantion < (en_frame.itr_radius + t_frame.body_radius) then
						for itr_id = 1, #en_frame.itrs do
							for body_id = 1, #t_frame.bodys do
								local itr = GetCollider(en_frame.itrs[itr_id], en)
								local body = GetCollider(t_frame.bodys[body_id], target)
								local result = collidersVerification(itr,body)
								if result.collision then
									local collision_entity = {
										target = t_id,
										itr = itr_id,
										body = body_id,
										info = result
									}
									table.insert(en.collisions, collision_entity)
								end
							end
						end
					end
				end

				if (en_frame.itr_radius > 0) and (t_frame.body_radius > 0) then
					if distantion < (en_frame.itr_radius + t_frame.body_radius) then
						for itr_id = 1, #en_frame.itrs do
							for body_id = 1, #t_frame.bodys do
								local itr = GetCollider(en_frame.itrs[itr_id], en)
								local body = GetCollider(t_frame.bodys[body_id], target)
								local result = collidersVerification(itr,body)
								if result.collision then
									local collision_entity = {
										target = t_id,
										itr = itr_id,
										body = body_id,
										info = result
									}
									table.insert(en.collisions, collision_entity)
								end
							end
						end
					end
				end
			end
		end
	end
end