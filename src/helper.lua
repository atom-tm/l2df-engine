local helper = { }

	--- Creates a hook for table's event / function.
	-- @param obj, table          table to hook
	-- @param key, string         table's event / function to hook
	-- @param callback, function  Hook's callback function
	-- @param caller, table       Optional. First parameter to callback function
	function helper.hook(obj, key, callback, caller)
		assert(type(callback) == "function", "Parameter 'callback' must be a function")

		local old = obj[key]
		if caller and old then
			obj[key] = function (...)
				old(...)
				callback(caller, ...)
			end
		elseif caller then
			obj[key] = function (...)
				callback(caller, ...)
			end
		elseif old then
			obj[key] = function (...)
				old(...)
				callback(...)
			end
		else
			obj[key] = callback
		end
	end

	--- Require all scripts from specified directory. Returns table with them.
	-- @param folderpath, string     Scripts folderpath
	-- @param pattern, string  If specified only scripts that match pattern would be loaded
	-- @return table
	function helper.requireFolder(folderpath, keys, pattern)
		local fs = love and love.filesystem
		local r = { }
		if not fs then return r end
		if not (folderpath and fs.getInfo(folderpath, 'directory')) then return r end
		folderpath = folderpath:find('/$') and folderpath or folderpath .. '/'
		local files = fs.getDirectoryItems(folderpath)
		folderpath = folderpath:gsub('/', '.')
		for i = 1, #files do
			if (not pattern or files[i]:find(pattern)) and files[i]:find('.lua$') then
				local file = files[i]:gsub('.lua$', '')
				local id = keys and file or #r + 1
				r[id] = require(folderpath .. file)
			end
		end
		return r
	end

	function helper.requireFile(filepath)
		local fs = love and love.filesystem
		if not (filepath and fs and fs.getInfo(filepath, 'file') and filepath:find('.lua$')) then return end
		local file = filepath:gsub(filepath:gsub('[^/]+$', ''), ''):gsub('.lua$', '')
		return require(filepath:gsub('.lua$', ''):gsub('/', '.')), file
	end

	--- Deep-copy of table
	-- @param table, table  Given table
	-- @param result, table
	function helper.copyTable(table, result)
		result = result or { }
		if type(result) ~= "table" then
			return result
		end
		if type(table) ~= "table" then
			return table
		end

		for key, val in pairs(table) do
			if type(val) == "table" and val.___class == nil then
				result[key] = helper.copyTable(val, result[key])
			else
				result[key] = val
			end
		end
		return result
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
		if var ~= nil then
			return var
		else
			return default
		end
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

return helper