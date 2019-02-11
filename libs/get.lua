local get = {}

	function get.NotZero (var, alternative) -- провека переменной на ноль или пустоту
	-------------------------------------
		if var ~= nil and var ~= 0 and var ~= "" then
			return var
		elseif alternative ~= nil then
			return alternative
		else return 1 end
	end

	function get.notNil (n,a) -- провека переменной на ноль или пустоту
	-------------------------------------
		if n ~= nil then return n
		else return a end
	end

	function get.Maximum (mas) -- получение максимального значения массива чисел
	-------------------------------------
		max = 0
		for i = 1, #mas do 
			if mas[i] > max then max = mas[i] end
		end
		return max
	end

	function get.Biggest(x,y) -- получение большего из двух значений
	-------------------------------------
		if x > y then
			return x
		else
		    return y
		end
	end

	function get.Least(x,y) -- получение меньшего из двух значений
	-------------------------------------
		if x < y then
			return x
		else
		    return y
		end
	end

	function get.Distance (x1,y1,x2,y2) -- получение дистанции между двумя игроками
	-------------------------------------
		return math.sqrt(math.abs((x1 - x2)^2) + math.abs((y1 - y2)^2))
	end

	function get.PString (string, parameter) -- функция для получения строкового значения параметра "parameter" из входящей строки "string"
	-------------------------------------
		local result = ""
		local match = string.match(string, parameter..": ([%w_]+)")
		if match ~= nil then result = tostring(match) end
		return result
	end

	function get.PNumber (string, parameter, alternative) -- функция для получения числового значения параметра из входящей строки
	-------------------------------------
		local result = 0
		if alternative ~= nil then
			result = alternative
		end
		local match = string.match(string, parameter..": ([-%d%.]+)")
		if match ~= nil then result = tonumber(match) end
		return result
	end

	function get.PBool (string, parameter) -- функция для получения булевого значения параметра из входящей строки
	-------------------------------------
		local result = false
		local match = string.match(string, parameter..": (%w+)")
		if match == "true" then result = true else result = false end
		return result
	end

	function get.PFrames (string, parameter) -- функция для получения списка значений парамеира из входящей строки
	-------------------------------------
		local frame_list = {}
		local frames = string.match(string, parameter .. ": {([^{}]*)}")
		if frames ~= nil then
			for frame in string.gmatch(frames, "(%d+)") do
				table.insert(frame_list, tonumber(frame))
			end
		end
		return frame_list
	end

	function get.PFramesString (string, parameter) -- функция для получения списка значений парамеира из входящей строки
	-------------------------------------
		local frame_list = {}
		local frames = string.match(string, parameter .. ": {([^{}]*)}")
		if frames ~= nil then
			for frame in string.gmatch(frames, "(%d+)") do
				table.insert(frame_list, frame)
			end
		end
		return frame_list
	end

return get