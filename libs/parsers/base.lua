local strmatch = string.match
local fs = love and love.filesystem

local Object = require "libs.object"
local Parser = Object:extend()

	--- Base method for parsing file
	-- @param filepath, string  Path to file for parsing
	-- @return table
	function Parser:parseFile(filepath)
		assert(type(filepath) == "string", "Parameter 'filepath' must be a string.")
		if fs then
			return self:parse( fs.read(filepath) )
		else
			local io = require "io"
			f = io.open(filepath)
			if f then
				local str = f:read("*a")
				f:close()
				return self:parse(str)
			end
		end
		return nil
	end

	--- Base method for parsing string
	-- @param str, string  String for parsing
	-- @return table
	function Parser:parse(str)
		assert(type(str) == "string", "Parameter 'str' must be a string.")
		return nil
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