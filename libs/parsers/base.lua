local strmatch = string.match
local fs = love and love.filesystem

local Object = require "libs.object"
local Parser = Object:extend()

	--- Base method for parsing file
	-- You can extend existing object by passing it as second parameter.
	-- @param filepath, string  Path to file for parsing
	-- @param obj, table        Object to extend, optional.
	-- @return table
	function Parser:parseFile(filepath, obj)
		assert(type(filepath) == "string", "Parameter 'filepath' must be a string.")
		if fs and fs.getInfo(filepath) then
			return self:parse(fs.read(filepath), obj)
		else
			local io = require "io"
			f = io.open(filepath)
			if f then
				local str = f:read("*a")
				f:close()
				return self:parse(str, obj)
			end
		end
		return nil
	end

	--- Base method for parsing string
	-- You can extend existing object by passing it as second parameter.
	-- @param str, string  String for parsing
	-- @param obj, table   Object to extend, optional.
	-- @return table
	function Parser:parse(str, obj)
		assert(type(str) == "string", "Parameter 'str' must be a string.")
		return obj
	end

	--- Method that tries to deduce type for given string. Returns casted value.
	-- @param str, string  String for parsing
	-- @return mixed
	function Parser:parseScalar(str)
		-- TODO: make stronger regex
		assert(type(str) == "string", "Parameter 'str' must be a string.")
		if tonumber(str) then
			return tonumber(str)
		elseif strmatch(str, "true") then
			return true
		elseif strmatch(str, "false") then
			return false
		end
		return str
	end

	--- Base method for dumping table
	-- @param str, string  String for parsing
	-- @return string
	function Parser:dump(data)
		assert(type(str) == "table", "Parameter 'str' must be a table.")
		return tostring(data)
	end

return Parser