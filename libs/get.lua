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

function GetDistance (x1,y1,x2,y2)
	return math.sqrt(((x1 - x2) * (x1 - x2)) + ((y1 - y2) * (y1 - y2)))
end