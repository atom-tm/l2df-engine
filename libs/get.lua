function GetFrame (en, num)
	local frame
	if num ~= nil then
		frame = en.frames[num]
	else
		frame = en.frames[en.frame]
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
	return math.sqrt(math.abs((x1 - x2)^2) + math.abs((y1 - y2)^2))
end



function PString (string, parameter) -- функция для получения строкового значения параметра "parameter" из входящей строки "string"
-------------------------------------
	local result = ""

	local match = string.match(string, parameter..": ([%w_]+)")
	if match ~= nil then result = tostring(match) end

	return result
end



function PNumber (string, parameter, alternative) -- функция для получения числового значения параметра "parameter" из входящей строки "string"
-------------------------------------
	local result = 0

	if alternative ~= nil then
		result = alternative
	end

	local match = string.match(string, parameter..": ([-%d%.]+)")
	if match ~= nil then result = tonumber(match) end

	return result
end



function PBool (string, parameter) -- функция для получения булевого значения параметра "parameter" из входящей строки "string"
-------------------------------------
	local result = false

	local match = string.match(string, parameter..": (%w+)")
	if match == "true" then result = true else result = false end

	return result
end