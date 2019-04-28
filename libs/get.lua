local get = {}

	-- Get sign of value
	-- @param x, number  Specified value
	-- @return number
	function get.sign(x)
		if x < 0 then return -1 end
		if x > 0 then return 1 end
		return 0
	end

	-- Get rounded value with precision
	-- @param value, number      Specified value
	-- @param precision, number  Needed precision
	-- @return number
	function get.round(value, precision)
		local i = math.pow(10, precision)
		return math.floor(value * i) / i
	end

	-- Returns true if frame with specified number exists
	-- @param frame, number   Value to check
	-- @param number, number  Default value. 1 if not setted
	-- @return boolean
	function get.stateExist(frame, number)
		for i = 1, #frame.states do
			if frame.states[i].number == tostring(number) then return true end
		end
		return false
	end

	-- Coalesce function for 'non-empty' value
	-- @param var, mixed      Value to check
	-- @param default, mixed  Default value. 1 if not setted
	-- @return mixed
	function get.NotZero(var, default)
		return (var ~= nil and var ~= 0 and var ~= "") and var or default or 1
	end

	-- Coalesce function for 'non-nil' value
	-- @param value, mixed    Value to check
	-- @param default, mixed  Default value. nil if not setted
	-- @return mixed
	function get.notNil(var, default)
		return var or default
	end

	-- Get maximum of array
	-- @param arr, array  Array to process
	-- @return int
	function get.Maximum(arr)
		max = 0
		for i = 1, #arr do 
			if arr[i] > max then max = arr[i] end
		end
		return max
	end

	-- Get maximum of two values
	-- @param x, mixed  First value
	-- @param y, mixed  Second value
	-- @return mixed
	function get.Biggest(x, y)
		if x > y then
			return x
		end
		return y
	end

	-- Get minimum of two values
	-- @param x, mixed  First value
	-- @param y, mixed  Second value
	-- @return mixed
	function get.Least(x, y)
		if x < y then
			return x
		end
		return y
	end

	-- Get distance between two points
	-- @param x1, number  First point x
	-- @param y1, number  First point y
	-- @param x2, number  Second point x
	-- @param y2, number  Second point y
	-- @return number
	function get.Distance(x1, y1, x2, y2)
		return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
	end

	-- Get string value from string by parameter
	-- @param str, string        Given string
	-- @param parameter, string  Parameter name
	-- @return string
	function get.PString(string, parameter)
		local match = string.match(str, parameter .. ": ([%w_]+)")
		return match and tostring(match) or ""
	end

	-- Get number value from string by parameter or default
	-- @param str, string        Given string
	-- @param parameter, string  Parameter name
	-- @param default, number    Default value. 0 if not setted
	-- @return number
	function get.PNumber(string, parameter, default)
		local match = string.match(string, parameter .. ": ([-%d%.]+)")
		return match and tonumber(match) or default or 0
	end

	-- Get boolean value from string by parameter or false by default
	-- @param str, string        Given string
	-- @param parameter, string  Parameter name
	-- @return boolean
	function get.PBool(string, parameter)
		local match = string.match(string, parameter .. ": (%w+)")
		return match == "true"
	end

	-- Get frames list (integer) from string by parameter. Empty by default
	-- @param str, string        Given string
	-- @param parameter, string  Parameter name
	-- @return table
	function get.PFrames(string, parameter)
		local frame_list = {}
		local frames = string.match(string, parameter .. ": {([^{}]*)}")
		if frames ~= nil then
			for frame in string.gmatch(frames, "(%d+)") do
				table.insert(frame_list, tonumber(frame))
			end
		end
		return frame_list
	end

	-- Get frames list (string) from string by parameter. Empty by default
	-- @param str, string        Given string
	-- @param parameter, string  Parameter name
	-- @return table
	function get.PFramesString(string, parameter)
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