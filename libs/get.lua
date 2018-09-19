function GetFrame (en, num)
	local frame
	if num ~= nil then
		frame = en.frames[tostring(num)]
	else
		frame = en.frames[tostring(en.frame)]
	end
	return frame
end



function FindMaximum (mas)
	max = 0
	for i = 1, #mas do 
		if mas[i] > max then max = mas[i] end
	end
	return max
end



function Get(var)
	local result
	if not (var == nil) then
		result = var
	else
		result = 0
	end
	return result
end



function GetCollider(collider, en) -- возвращает коллайдер персонажа, при этом высчитывает реальные координаты этого коллайдера
-------------------------------------
	local result = {}

	local frame = en.frames[tostring(en.frame)] -- получаем фрейм объекта

	if en.facing == 1 then -- проверка на facing
		result.x = en.x + collider.x - frame.centerx -- получаем x коллайдера
	else
		result.x = en.x - collider.x + frame.centerx - collider.w -- x, если объект повёрнут
	end

	result.y = en.y + collider.y - Get(frame.centery) -- получаем y коллайдера

	result.w = collider.w
	result.h = collider.h

	return result -- возвращаем коллайдер

end