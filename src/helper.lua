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
local strbyte = string.byte
local strlen = string.len
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

local CRC32 = {
	0x00000000, 0x77073096, 0xee0e612c, 0x990951ba,     0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3,
	0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,     0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91,
	0x1db71064, 0x6ab020f2, 0xf3b97148, 0x84be41de,     0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
	0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec,     0x14015c4f, 0x63066cd9, 0xfa0f3d63, 0x8d080df5,
	0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,     0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,
	0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940,     0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
	0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116,     0x21b4f4b5, 0x56b3c423, 0xcfba9599, 0xb8bda50f,
	0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,     0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,
	0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a,     0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
	0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818,     0x7f6a0dbb, 0x086d3d2d, 0x91646c97, 0xe6635c01,
	0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,     0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457,
	0x65b0d9c6, 0x12b7e950, 0x8bbeb8ea, 0xfcb9887c,     0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
	0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2,     0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb,
	0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,     0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9,
	0x5005713c, 0x270241aa, 0xbe0b1010, 0xc90c2086,     0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
	0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4,     0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad,
	0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,     0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683,
	0xe3630b12, 0x94643b84, 0x0d6d6a3e, 0x7a6a5aa8,     0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
	0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe,     0xf762575d, 0x806567cb, 0x196c3671, 0x6e6b06e7,
	0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,     0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5,
	0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252,     0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
	0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60,     0xdf60efc3, 0xa867df55, 0x316e8eef, 0x4669be79,
	0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,     0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f,
	0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04,     0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
	0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a,     0x9c0906a9, 0xeb0e363f, 0x72076785, 0x05005713,
	0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,     0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21,
	0x86d3d2d4, 0xf1d4e242, 0x68ddb3f8, 0x1fda836e,     0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
	0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c,     0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45,
	0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,     0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db,
	0xaed16a4a, 0xd9d65adc, 0x40df0b66, 0x37d83bf0,     0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
	0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6,     0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
	0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,     0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d,
}

local MAX_INT = 2 ^ 32
local cacheCount = 0
local cacheTable = { }

local helper = { }

	--- Serialize variable to string.
	-- @param mixed var  Variable to dump.
	-- @return string
	function helper.dump(var)
	  return dump(var)
	end

	function helper.bitor(x, y)
		local k, c = 1, 0
		while x + y > 0 do
			local rx, ry = x % 2, y % 2
			if rx + ry > 0 then c = c + k end
			x, y, k = (x - rx) / 2, (y - ry) / 2, k * 2
		end
		return c
	end

	function helper.bitxor(x, y)
		local k, c = 1, 0
		while x > 0 and y > 0 do
			local rx, ry = x % 2, y % 2
			if rx ~= ry then c = c + k end
			x, y, k = (x - rx) / 2, (y - ry) / 2, k * 2
		end
		x = x < y and y or x
		while x > 0 do
			local rx = x % 2
			if rx > 0 then c = c + k end
			x, k = (x - rx) / 2, k * 2
		end
		return c
	end

	function helper.bitand(x, y)
		local k, c = 1, 0
		while x > 0 and y > 0 do
			local rx, ry = x % 2, y % 2
			if rx == 1 and ry == 1 then c = c + k end
			x, y, k = (x - rx) / 2, (y - ry) / 2, k * 2
		end
		return c
	end

	function helper.rshift(x, y)
		return floor(x / (2 ^ y))
	end

	local rshift, bitand, bitxor = helper.rshift, helper.bitand, helper.bitxor
	function helper.crc32(data, crc)
		data = tostring(data)
		crc = crc and bitxor(crc, 0xFFFFFFFF) or 0xFFFFFFFF
		for i = 1, strlen(data) do
			local byte = strbyte(data, i)
			crc = bitxor(rshift(crc, 8), CRC32[bitxor(bitand(crc, 0xFF), byte) + 1])
		end
		crc = bitxor(crc, 0xFFFFFFFF)
		return crc < 0 and crc + MAX_INT or crc
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
		-- TODO: is it really needed?
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

	--- Get minimum of table.
	-- @param table arr  Table to process.
	-- @return int
	function helper.minimum(var)
		local min = MAX_INT
		for _, v in pairs(var) do
			if v < min then min = v end
		end
		return min
	end

	--- Get maximum of table.
	-- @param table arr  Table to process.
	-- @return int
	function helper.maximum(var)
		local max = 0
		for _, v in pairs(var) do
			if v > max then max = v end
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