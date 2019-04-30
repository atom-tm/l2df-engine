local helper = {}

	--- Require all scripts from specified directory. Returns table with them.
	-- @param path, string     Scripts path
	-- @param pattern, string  If specified only scripts that match pattern would be loaded
	-- @return table
	function helper.requireAllFromFolder(path, pattern)
		local result = {}
		local file_list = love.filesystem.getDirectoryItems(path)
		if file_list then
			local formated_path = ""
			for folder in string.gmatch(path, "([^/]+)") do
				formated_path = formated_path .. folder .. "."
			end
			for i = 1, #file_list do
				if file_list[i]:find("^[%a%d_]+%.lua$") then
					local file_name = file_list[i]:gsub(".lua$","")
					if not pattern or file_name:find(pattern) then
						result[tostring(file_name)] = require(formated_path .. file_name)
					end
				end
			end
		end
		return result
	end

	--- Update window size by settings
	function helper.SetWindowSize()
		local width = settings.windowSizes[settings.window.selectedSize].width
		local height = settings.windowSizes[settings.window.selectedSize].height
		settings.window.width = width
		settings.window.height = height

		love.window.setMode(width, height)
		love.window.setFullscreen(settings.window.fullscreen)
		if settings.window.fullscreen then
			width, height = love.window.getMode() 
		end

		camera = gamera.new(0, 0, settings.gameWidth, settings.gameHeight)
		camera:setWindow(0, 0, width, height)
		settings.window.cameraScale = height / settings.gameHeight
		camera:setScale(settings.window.cameraScale)
		settings.window.realHeight = height
		settings.window.realWidth = width
	end

	--- Deep-copy of table
	-- @param table, table  Given string
	function helper.CopyTable(table)
		local result = {}
		for key, val in pairs(table) do
			if type(val) == "table" then
				result[key] = helper.CopyTable(val)
			else
				result[key] = val
			end
		end
		return result
	end

	--- Get damage information by key
	-- @abelidze: Я думаю, что это может быть trait, а не helper
	-- @param val, string|number  Specified key
	function helper:getDamageInfo(val)
		if self[val] then
			if type(self[val]) == "number" then
				return self[val]
			elseif type(self[val]) == "table" then
				return self[val][math.random(1, #self[val])]
			end
		end
		return 0
	end

	--- Trim spaces at start and end of string
	-- @param str, string  Given string
	-- @return string
	function helper.trim(str)
		return str:gsub("^%s*(.-)%s*$", "%1")
	end

	--- Get sign of value
	-- @param x, number  Specified value
	-- @return number
	function helper.sign(x)
		return x > 0 and 1 or x < 0 and -1 or 0
	end

	--- Get rounded value with precision
	-- @param value, number      Specified value
	-- @param precision, number  Needed precision
	-- @return number
	function helper.round(value, precision)
		local i = math.pow(10, precision)
		return math.floor(value * i) / i
	end

	--- Returns true if frame with specified number exists
	-- @param frame, number   Value to check
	-- @param number, number  Default value. 1 if not setted
	-- @return boolean
	function helper.stateExist(frame, number)
		for i = 1, #frame.states do
			if frame.states[i].number == tostring(number) then return true end
		end
		return false
	end

	--- Coalesce function for 'non-empty' value
	-- @param var, mixed      Value to check
	-- @param default, mixed  Default value. 1 if not setted
	-- @return mixed
	function helper.NotZero(var, default)
		return (var ~= nil and var ~= 0 and var ~= "") and var or default or 1
	end

	--- Coalesce function for 'non-nil' value
	-- @param value, mixed    Value to check
	-- @param default, mixed  Default value. nil if not setted
	-- @return mixed
	function helper.notNil(var, default)
		return var or default
	end

	--- Get maximum of array
	-- @param arr, array  Array to process
	-- @return int
	function helper.Maximum(arr)
		max = 0
		for i = 1, #arr do 
			if arr[i] > max then max = arr[i] end
		end
		return max
	end

	--- Get maximum of two values
	-- @param x, mixed  First value
	-- @param y, mixed  Second value
	-- @return mixed
	function helper.max(x, y)
		if x > y then
			return x
		end
		return y
	end

	--- Get minimum of two values
	-- @param x, mixed  First value
	-- @param y, mixed  Second value
	-- @return mixed
	function helper.min(x, y)
		if x < y then
			return x
		end
		return y
	end

	--- Get distance between two points
	-- @param x1, number  First point x
	-- @param y1, number  First point y
	-- @param x2, number  Second point x
	-- @param y2, number  Second point y
	-- @return number
	function helper.Distance(x1, y1, x2, y2)
		return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
	end

	--- Get string value from string by parameter
	-- @param str, string        Given string
	-- @param parameter, string  Parameter name
	-- @return string
	function helper.PString(str, parameter)
		local match = string.match(str, parameter .. ": ([%w_]+)")
		return match and tostring(match) or ""
	end

	--- Get number value from string by parameter or default
	-- @param str, string        Given string
	-- @param parameter, string  Parameter name
	-- @param default, number    Default value. 0 if not setted
	-- @return number
	function helper.PNumber(str, parameter, default)
		local match = string.match(str, parameter .. ": ([-%d%.]+)")
		return match and tonumber(match) or default or 0
	end

	--- Get boolean value from string by parameter or false by default
	-- @param str, string        Given string
	-- @param parameter, string  Parameter name
	-- @return boolean
	function helper.PBool(str, parameter)
		local match = string.match(str, parameter .. ": (%w+)")
		return match == "true"
	end

	--- Get frames list (integer) from string by parameter. Empty by default
	-- @param str, string        Given string
	-- @param parameter, string  Parameter name
	-- @return table
	function helper.PFrames(str, parameter)
		local frame_list = {}
		local frames = string.match(str, parameter .. ": {([^{}]*)}")
		if frames ~= nil then
			for frame in string.gmatch(frames, "(%d+)") do
				table.insert(frame_list, tonumber(frame))
			end
		end
		return frame_list
	end

	--- Get frames list (string) from string by parameter. Empty by default
	-- @param str, string        Given string
	-- @param parameter, string  Parameter name
	-- @return table
	function helper.PFramesString(str, parameter)
		local frame_list = {}
		local frames = string.match(str, parameter .. ": {([^{}]*)}")
		if frames ~= nil then
			for frame in string.gmatch(frames, "(%d+)") do
				table.insert(frame_list, frame)
			end
		end
		return frame_list
	end

return helper