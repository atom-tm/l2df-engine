--- Utility functions collection.
-- @module l2df.helper
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)[^%.]+$') or '') .. 'core')
local fs = core.api.io

local strgmatch = string.gmatch
local strformat = string.format
local strjoin = table.concat
local strfind = string.find
local strgsub = string.gsub
local strsub = string.sub
local strrep = string.rep
local floor = math.floor
local sqrt = math.sqrt
local pow = math.pow
local abs = math.abs
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
		indent = indent or 1
		if indent > 8 then
			return tostring(t)
		end
		stack = stack or { }
		if stack[t] then return '{"cycle:' .. tostring(t) .. '"}' end
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

local cacheCount = 0
local cacheTable = { }

local helper = { }

	--- Serialize variable to string.
	-- @param mixed var  Variable to dump.
	-- @return string
	function helper.dump(var)
	  return dump(var)
	end

	--- Creates a hook for table's event / function.
	-- @param table obj  Table to hook.
	-- @param string key  Table's event / function to hook.
	-- @param function callback  Hook's callback function.
	-- @param[opt] table caller  First parameter to callback function.
	function helper.hook(obj, key, callback, caller)
		assert(type(callback) == 'function', 'Parameter "callback" must be a function')

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

	--- Require all scripts from specified directory. Returns table with them.
	-- @param string folderpath  Scripts folderpath.
	-- @param[opt=false] boolean keys  Use filenames instead of autoincremental indexes as table's keys.
	-- @param[opt] string pattern  If specified only scripts that match pattern would be loaded.
	-- @return table
	function helper.requireFolder(folderpath, keys, pattern)
		local result = { }
		if fs and folderpath and fs.getInfo(folderpath, 'directory') then
			folderpath = strfind(folderpath, '/$') and folderpath or folderpath .. '/'
			local modulepath = core.modulepath(folderpath)
			local files = fs.directoryItems(folderpath)
			local parser = core.import 'class.parser.lffs2'
			local id, file
			for i = 1, #files do
				if not pattern or strfind(files[i], pattern) then
					if strfind(files[i], '.lua$') then
						file = strgsub(files[i], '.lua$', '')
						id = keys and file or #result + 1
						result[id] = require(modulepath .. file)
					elseif strfind(files[i], '.dat$') then
						file = files[i]
						id = keys and file or #result + 1
						id = strgsub(id, '.dat$', '')
						local s = fs.read(folderpath .. file)
						result[id] = parser:parse(s)
					end
				end
			end
		end
		return result
	end

	--- Require a script from file. Returns loaded module and its filename.
	-- @param string filepath  Path to the script-file.
	-- @return table
	-- @return string
	function helper.requireFile(filepath)
		if not (filepath and fs and fs.getInfo(filepath, 'file') and strfind(filepath, '.lua$')) then return end
		local file = filepath:gsub(filepath:gsub('[^/]+$', ''), ''):gsub('.lua$', '')
		return require(filepath:gsub('.lua$', ''):gsub('/', '.')), file
	end

	--- Allocate new table from pool.
	-- @return table
    function helper.newTable()
        if cacheCount == 0 then
            helper.freeTable { }
        end
        local table = cacheTable[cacheCount]
        cacheTable[cacheCount] = nil
        cacheCount = cacheCount - 1
        return table
    end

    --- Dispose table and return it back to pool.
    -- @param table table
    function helper.freeTable(table)
        for k in pairs(table) do
            table[k] = nil
        end
        cacheCount = cacheCount + 1
        cacheTable[cacheCount] = table
    end

	--- Deep-copy of the table.
	-- @param table table  Given table.
	-- @param[opt] table result  Resulting table. Can be used for the in-place updating.
	-- @return table
	function helper.copyTable(table, result)
		result = result or { }
		if type(result) ~= 'table' then
			return result
		elseif type(table) ~= 'table' then
			return table
		end
		for key, val in pairs(table) do
			if not table.___shallow and type(val) == 'table' and val.___class == nil then
				result[key] = helper.copyTable(val, not val.___nomerge and result[key] or nil)
			else
				result[key] = val
			end
		end
		if table.___hasnil then
			for key, val in pairs(result) do
				if not table[key] then
					result[key] = nil
				end
			end
		end
		for i = #table + 1, #result do
			result[i] = nil
		end
		return result
	end

	--- Get the plural form of the word.
	-- @param string str  Word in the singular form.
	-- @return string
	function helper.plural(str)
		if type(str) ~= 'string' then
			return str
		end
		local last = strsub(str, #str, -1)
		if last == 'y' then
			return strsub(str, 1, -2) .. 'ies'
		elseif last == 'x' or last == 'o' or last == 'z' or last == 's' or last == 'h' then
			return str .. 'es'
		end
		return str .. 's'
	end

	--- Get the singular form of the word.
	-- @param string str  Word in the plural form.
	-- @return string
	function helper.singular(str)
		if type(str) ~= 'string' then
			return str
		end
		local len = #str
		local l1 = strsub(str, len - 0, -1)
		local l2 = strsub(str, len - 1, -2)
		local l3 = strsub(str, len - 2, -3)
		if l1 ~= 's' then
			return str
		elseif l2 == 'e' and l3 == 'i' then
			return strsub(str, 1, -4) .. 'y'
		elseif l2 == 'e' and (l3 == 'x' or l3 == 'o' or l3 == 'z' or l3 == 's' or l3 == 'h') then
			return strsub(str, 1, -4)
		end
		return strsub(str, 1, -2)
	end

	--- Determine if object is an instance of a specified class.
	-- @param table object  Intance to check.
	-- @param table class  Class to check.
	-- @return boolean
	function helper.isClass(object, class)
        return type(object) == 'table' and object.isInstanceOf and object:isInstanceOf(class) or false
    end

	--- Determine if object is array or not.
	-- @param mixed obj  Object to check.
	-- @return boolean
	function helper.isArray(obj)
		return type(obj) == 'table' and (obj[1] ~= nil or next(obj) == nil) or false
	end

	--- Convert iterator to array
	-- @return table
	function helper.array(...)
		local arr = { }
		local i = 1
		for v in ... do
			arr[i] = v
			i = i + 1
		end
		return arr
	end

	--- Splitting string to array by separator.
	-- @param string str  Source string.
	-- @param[opt] string sep  Separator string.
	-- @return table
	function helper.split(str, sep)
		if not sep or sep == '' then
			return helper.array(strgmatch(str, '([%S]+)'))
		end
		local psep = strgsub(sep, '[%(%)%.%%%+%-%*%?%[%]%^%$]', '%%%1')
		return helper.array(strgmatch(str .. sep, '(.-)(' .. psep .. ')'))
	end

	--- Trim spaces at start and end of string.
	-- @param string str  Source string.
	-- @return string
	function helper.trim(str)
		return strgsub(str, '^%s*(.-)%s*$', '%1')
	end

	--- Get sign of value.
	-- @param number x  Specified value.
	-- @return number
	function helper.sign(x)
		return x > 0 and 1 or x < 0 and -1 or 0
	end

	--- Clamp variable between two edges.
	-- @param number val  Source value.
	-- @param number min  Left (minimum) bound of the value.
	-- @param number max  Right (maximum) bound of the value.
	-- @return number
	function helper.clamp(val, min, max)
		return val < min and min or (val > max and max or val)
	end

	--- Get the nearest boundary.
	-- @param number val  Source value.
	-- @param number min  Left (minimum) bound of the value.
	-- @param number max  Right (maximum) bound of the value.
	-- @return number
	function helper.nearest(val, min, max)
		return abs(val - min) < abs(val - max) and min or max
	end

	--- Find out if the object is within the specified values.
	-- @param number val  Source value.
	-- @param number min  Left (minimum) bound of the value.
	-- @param number max  Right (maximum) bound of the value.
	-- @return boolean
	function helper.bound(val, min, max)
		return type(val) == 'number' and val > min and val < max and val or false
	end

	--- Get rounded value with precision.
	-- @param number value  Source value.
	-- @param number precision  Required precision.
	-- @return number
	function helper.round(value, precision)
		local i = pow(10, precision or 0)
		return floor(value * i + 0.5) / i
	end

	--- Coalesce function for 'non-empty' value.
	-- @param mixed var  Value to check.
	-- @param[opt=1] mixed default  Default value.
	-- @return mixed
	function helper.notZero(var, default)
		return (var ~= nil and var ~= 0 and var ~= '') and var or default or 1
	end

	--- Coalesce function for 'non-nil' value.
	-- @param mixed value  Value to check.
	-- @param[opt=nil] mixed default  Default value.
	-- @return mixed
	function helper.notNil(value, default)
		if value ~= nil then
			return value
		end
		return default
	end

	--- Get maximum of array.
	-- @param table arr  Array to process.
	-- @return int
	function helper.maximum(arr)
		local max = 0
		for i = 1, #arr do
			if arr[i] > max then max = arr[i] end
		end
		return max
	end

	--- Get maximum of two values.
	-- @param mixed x  First value.
	-- @param mixed y  Second value.
	-- @return mixed
	function helper.max(x, y)
		if x > y then
			return x
		end
		return y
	end

	--- Get minimum of two values.
	-- @param mixed x  First value.
	-- @param mixed y  Second value.
	-- @return mixed
	function helper.min(x, y)
		if x < y then
			return x
		end
		return y
	end

	--- Linear interpolation beetween two values.
	-- @param number a  Start value.
	-- @param number b  End value.
	-- @param number ratio  Value used to interpolate between a and b.
	-- @return number
	function helper.lerp(a, b, ratio)
		return a + (b - a) * ratio
	end

	--- Get distance between two points.
	-- @param number x1  First point x.
	-- @param number y1  First point y.
	-- @param number x2  Second point x.
	-- @param number y2  Second point y.
	-- @return number
	function helper.distance(x1, y1, x2, y2)
		return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
	end

	--- Matrix multiplication.
	-- @param table m1  Left hand side matrix.
	-- @param table m2  Right hand side matrix.
	function helper.mulMatrix(m1, m2)
	    local r = { }
	    for n = 1, #m1 do
	        r[n] = { }
	        for i = 1, #m2[1] do
	            r[n][i] = 0
	            for j = 1, #m1[1] do
	                r[n][i] = r[n][i] + (m1[n][j] * m2[j][i])
	            end
	        end
	    end
	    return r
	end

return helper