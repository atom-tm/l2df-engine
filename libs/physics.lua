 local function collisionCheck(col1, col2) -- функция проверки двух коллайдеров на пересечение

	 local result = {
		 collision = false,
		 collision_center_x = "none",
		 collision_center_y = "none",
		 collision_direction_x = "undefined",
		 collision_direction_y = "undefined"
	 } -- переменная, которая будет возвращаться после выполнения функции сравнения

	 local col1x1 = col1.x -- получение координаты x1 первого коллайдера
	 local col1x2 = col1.x + col1.width -- получение координаты х2 первого коллайдера
	 local col1y1 = col1.y -- получение координаты y1 первого коллайдера
	 local col1y2 = col1.y + col1.height -- получение координаты y2 первого коллайдера
	
	 local col2x1 = col2.x -- получение координаты x1 второго коллайдера
	 local col2x2 = col2.x + col2.width -- получение координаты х2 второго коллайдера
	 local col2y1 = col2.y -- получение координаты y1 второго коллайдера
	 local col2y2 = col2.y + col2.height -- получение координаты y2 второго коллайдера

	 if (((math.abs(col1x1 - col2x1) + math.abs(col1x2 - col2x2)) <= (col1.width + col2.width)) and ((math.abs(col1y1 - col2y1) + math.abs(col1y2 - col2y2)) <= (col1.height + col2.height))) then
	 	 
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