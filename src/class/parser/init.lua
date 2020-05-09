--- Base class for parsers
-- @classmod l2df.class.parser
-- @author Abelidze
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)[^%.]+%.[^%.]+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Parsers works only with l2df v1.0 and higher')

local Class = core.import 'class'

local strmatch = string.match
local fopen = io.open
local fs = love and love.filesystem

local Parser = Class:extend()

	--- Base method for parsing file
	-- You can extend existing object by passing it as second parameter.
	-- @param string filepath  Path to file for parsing
	-- @param table obj  Object to extend, optional.
	-- @return table
	function Parser:parseFile(filepath, obj)
		assert(type(filepath) == 'string', 'Parameter "filepath" must be a string.')
		if fs and fs.getInfo(filepath) then
			return self:parse(fs.read(filepath), obj)
		else
			local f = fopen(filepath, 'r')
			if f then
				local str = f:read('*a')
				f:close()
				return self:parse(str, obj)
			end
		end
		return obj
	end

	--- Base method for parsing string
	-- You can extend existing object by passing it as second parameter.
	-- @param string str  String for parsing
	-- @param table obj  Object to extend, optional.
	-- @return table
	function Parser:parse(str, obj)
		assert(type(str) == 'string', 'Parameter "str" must be a string.')
		return obj
	end

	--- Method that tries to deduce type for given string. Returns casted value.
	-- @param string str  String for parsing
	-- @return mixed
	function Parser:parseScalar(str)
		-- TODO: make stronger regex
		assert(type(str) == 'string', 'Parameter "str" must be a string.')
		if tonumber(str) then
			return tonumber(str)
		elseif strmatch(str, 'true') then
			return true
		elseif strmatch(str, 'false') then
			return false
		end
		return str
	end

	--- Method for converting scalar value to string.
	-- @param string value  Value for dumping
	-- @return string
	function Parser:dumpScalar(value)
		local t = type(value)
		assert(t ~= 'function', 'Parameter "value" can\'t be a function.')

		if t == 'string' then
			return '\"' .. tostring(value) .. '\"'
		end
		return tostring(value)
	end

	--- Base method for dumping table to file
	-- @param string filepath  Path to file for dumping
	-- @param table data  Table for dumping
	-- @return table
	function Parser:dumpToFile(filepath, data)
		assert(type(filepath) == 'string', 'Parameter "filepath" must be a string.')

		data = self:dump(data)
		if fs then
			filepath = fs.getSource() .. '/' .. filepath
		end

		local f = fopen(filepath, 'w')
		if f then
			f:write(data)
			f:flush()
			f:close()
		end
		return nil
	end

	--- Base method for dumping table
	-- @param table data  Table for dumping
	-- @return string
	function Parser:dump(data)
		assert(type(data) == 'table', 'Parameter "data" must be a table.')
		return tostring(data)
	end

return Parser
