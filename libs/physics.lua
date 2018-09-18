function CollaidersVerification(col1, col2) -- функция проверки двух коллайдеров на пересечение
---------------------------------------------------------------------

	local result = {
		collision = false,
		collision_center_x = "none",
		collision_center_y = "none",
		collision_direction_x = "undefined",
		collision_direction_y = "undefined",
		entity_id = nil,
		collaider_id  = nil
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
			if (val.e_collaider.type == "position") and (val.t_collaider.type == "platform") then 
				en.in_air = true
			end
		end

		if en.in_air then 



		end
	end
end


function Motion(en_id, dt)
	en = entity_list[en_id]
	en.y = en.y + en.velocity_y * (dt * 100)
	en.x = en.x + en.velocity_x * (dt * 100)

	if (en.velocity_x ~= 0) or (en.velocity_y ~= 0) then
		CheckCollisions(en_id)
	end
end




function GetCollaiders(en) -- возвращает список коллайдеров персонажа, при этом высчитывает реальные координаты каждого коллайдера
-------------------------------------
	local collaiders = {}
	local frame = en.frames[tostring(en.frame)]

	for k, col in pairs(frame.collaiders) do

		local collaider = {}
		collaider.type = col.type
		if en.facing == 1 then
			collaider.x = en.x + col.x - frame.centerx
		else
			collaider.x = en.x - col.x + frame.centerx - col.w
		end
		collaider.y = en.y + col.y - Get(frame.centery)
		
		collaider.w = col.w
		collaider.h = col.h
		table.insert(collaiders, collaider)

	end

	return collaiders
end

function CheckCollisions(en_id) -- для каждого коллайдера каждого загруженного объекта проверяет столкновения с другими коллайдерами и записывает информацию обо всех столкновениях в датку персонажа
-------------------------------------
	en = entity_list[en_id]
	en.collisions = {}

	local en_collaiders = GetCollaiders(en)
	local position_collaider = {
		x = en.x,
		y = en.y,
		w = 1,
		h = 1,
		type = "position" 
	} -- проверка по позиции персонажа
	table.insert(en_collaiders, position_collaider)

	for t_id = 1, #entity_list do
		if t_id ~= en_id then
			target = entity_list[t_id]
			target_collaiders = GetCollaiders(target)
			for tc_id, target_collaider in ipairs(target_collaiders) do
				for ec_id, en_collaider in ipairs(en_collaiders) do
					if not (en_collaider.type == target_collaider.type) then
						local result = CollaidersVerification(en_collaider, target_collaider)
						if result.collision then
							local collision = {
								target = target,
								t_collaider = target_collaider,
								e_collaider = en_collaider,
								info = result
							} -- объект с информацией о коллизии
							if not (en_collaider == "position") then
								table.insert(en.collisions, collision)
							end
						end
					end
				end
			end
		end
	end
end



function CheckCollisions2(en_id)
	en = entity_list[en_id]
	en.collisions = {}
	
	for t_id = 1, #entity_list do
		if (t_id ~= en_id) and (entity_list[t_id] ~= nil) and (#entity_list[t_id].frames[entity_list[t_id].frame].collaiders > 0) then

		end
	end

	for i = 1, #entity_list do
		local collisions = GetCollaiders(entity_list[i])
		table.insert(collaiders, collisions)
	end
end