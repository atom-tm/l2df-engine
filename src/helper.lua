local core = l2df or require(((...):match('(.-)[^%.]+$') or '') .. 'core')
local fs = love and love.filesystem

local strgmatch = string.gmatch
local strformat = string.format
local strjoin = table.concat
local strfind = string.find
local strgsub = string.gsub
local strrep = string.rep
local floor = math.floor
local sqrt = math.sqrt
local pow = math.pow
local tostring = _G.tostring
local require = _G.require
local pairs = _G.pairs
local type = _G.type
local next = _G.next

local dump
local mapper = setmetatable({
	[ 'boolean'  ] = tostring,
	[ 'function' ] = tostring,
	[ 'userdata' ] = tostring,
	[ 'nil'      ] = tostring,
	[ 'string'   ] = function(v) return strformat('%q', v) end,
	[ 'number'   ] = function(v)
		if v ~= v then return '0/0'
		elseif v == 1 / 0 then return '1/0'
		elseif v == -1 / 0 then return '-1/0' end
		return tostring(v)
	end,
	[ 'table'    ] = function(t, stack, indent)
		stack = stack or { }
		indent = indent or 1
		if stack[t] then return '{"circular-reference"}' end
		local margin0 = strrep('  ', indent - 1)
		local margin1 = strrep('  ', indent)
		local result = { }
		stack[t] = true
		for k, v in pairs(t) do
			result[#result + 1] = strjoin({
				margin1,
				'[',
				dump(k, stack, indent + 1),
				'] = ',
				dump(v, stack, indent + 1)
			})
		end
		stack[t] = nil
		return strjoin({ '{\n', strjoin(result, ',\n'), '\n', margin0, '}'})
	end
}, { __index = function(_, t) return function() return '<' .. t .. '>' end end })

dump = function(x, stack, indent)
  return mapper[type(x)](x, stack, indent)
end

local helper = { }

	--- Creates a hook for table's event / function
	-- @param table obj          table to hook
	-- @param string key         table's event / function to hook
	-- @param function callback  Hook's callback function
	-- @param table caller       Optional. First parameter to callback function
	function helper.hook(obj, key, callback, caller)
		assert(type(callback) == "function", "Parameter 'callback' must be a function")

		local old = obj[key]
		if caller and old then
			obj[key] = function (...)
				local r = old(...)
				callback(caller, ...)
				return r
			end
		elseif caller then
			obj[key] = function (...)
				callback(caller, ...)
			end
		elseif caller == false and old then
			obj[key] = function (...)
				local r = old(...)
				callback(r, ...)
				return r
			end
		elseif old then
			obj[key] = function (...)
				local r = old(...)
				callback(...)
				return r
			end
		else
			obj[key] = callback
		end
	end

	--- Require all scripts from specified directory. Returns table with them
	-- @param string folderpath  Scripts folderpath
	-- @param boolean keys       Use filenames instead of autoincremental indexes as table's keys
	-- @param string pattern     If specified only scripts that match pattern would be loaded
	-- @return table
	function helper.requireFolder(folderpath, keys, pattern)
		local result = { }
		if fs and folderpath and fs.getInfo(folderpath, 'directory') then
			folderpath = strfind(folderpath, '/$') and folderpath or folderpath .. '/'

			local modulepath = core.modulepath(folderpath)
			local files = fs.getDirectoryItems(folderpath)

			local id, file
			for i = 1, #files do
				if (not pattern or strfind(files[i], pattern)) and strfind(files[i], '.lua$') then
					file = strgsub(files[i], '.lua$', '')
					id = keys and file or #result + 1
					result[id] = require(modulepath .. file)
				elseif (not pattern or strfind(files[i], pattern)) and strfind(files[i], '.dat$') then
					file = files[i]
					id = keys and file or #result + 1
					result[id] = parser:parse(fs.read(modulepath .. file))
				end
			end
		end
		return result
	end

	--- Require a script from file. Returns loaded module and its filename
	-- @param mixed var  Variable to dump
	-- @return string
	function helper.dump(var)
	  return dump(var)
	end

	--- Require a script from file. Returns loaded module and its filename
	-- @tparam string filepath
	-- @return table
	-- @return string
	function helper.requireFile(filepath)
		local fs = love and love.filesystem
		if not (filepath and fs and fs.getInfo(filepath, 'file') and strfind(filepath, '.lua$')) then return end
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

	--- Determine if object is array or not
	-- @param mixed obj  Object to check
	-- @return bool
	function helper.isArray(obj)
		return type(obj) == "table" and (obj[1] ~= nil or next(obj) == nil)
	end

	--- Convert iterator to array
	-- @return table
	function helper.array(...)
		local arr = { }
		local i = 1
		for v in ... do
			arr[1] = v
			i = i + 1
		end
		return arr
	end

	--- Splitting string to array by separator
	-- @param string str
	-- @param string sep
	-- @return table
	function helper.split(str, sep)
		if not sep or sep == '' then
			return helper.array(strgmatch(str, '([%S]+)'))
		end
		local psep = strgsub(sep, '[%(%)%.%%%+%-%*%?%[%]%^%$]', '%%%1')
		return helper.array(strgmatch(str .. sep, '(.-)(' .. psep .. ')'))
	end

	--- Trim spaces at start and end of string
	-- @param string str  Given string
	-- @return string
	function helper.trim(str)
		return strgsub(str, '^%s*(.-)%s*$', '%1')
	end

	--- Get sign of value
	-- @param number x  Specified value
	-- @return number
	function helper.sign(x)
		return x > 0 and 1 or x < 0 and -1 or 0
	end

	--- Get rounded value with precision
	-- @param number value      Specified value
	-- @param number precision  Needed precision
	-- @return number
	function helper.round(value, precision)
		local i = pow(10, precision)
		return floor(value * i) / i
	end

	--- Coalesce function for 'non-empty' value
	-- @param mixed var      Value to check
	-- @param mixed default  Default value. 1 if not setted
	-- @return mixed
	function helper.notZero(var, default)
		return (var ~= nil and var ~= 0 and var ~= "") and var or default or 1
	end

	--- Coalesce function for 'non-nil' value
	-- @param mixed value    Value to check
	-- @param mixed default  Default value. nil if not setted
	-- @return mixed
	function helper.notNil(var, default)
		if var ~= nil then
			return var
		end
		return default
	end

	--- Get maximum of array
	-- @param arr, array  Array to process
	-- @return int
	function helper.maximum(arr)
		max = 0
		for i = 1, #arr do
			if arr[i] > max then max = arr[i] end
		end
		return max
	end

	--- Get maximum of two values
	-- @param mixed x  First value
	-- @param mixed y  Second value
	-- @return mixed
	function helper.max(x, y)
		if x > y then
			return x
		end
		return y
	end

	--- Get minimum of two values
	-- @param mixed x  First value
	-- @param mixed y  Second value
	-- @return mixed
	function helper.min(x, y)
		if x < y then
			return x
		end
		return y
	end

	--- Get distance between two points
	-- @param number x1  First point x
	-- @param number y1  First point y
	-- @param number x2  Second point x
	-- @param number y2  Second point y
	-- @return number
	function helper.distance(x1, y1, x2, y2)
		return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
	end

return helper