local DatParser = require "libs.parsers.base"
local LfParser = DatParser:extend()

	--- Method for parsing lf2 formatted string
	-- @param str, string  String for parsing
	-- @return table
	function LfParser.parse(str)
		assert(type(str) == "string", "Parameter 'str' must be a string.")
		return json:decode(str)
	end

	--- Method for dumping table to lf2 format
	-- @param str, string  String for parsing
	-- @return string
	function LfParser.dump(data)
		assert(type(str) == "table", "Parameter 'str' must be a table.")
		return json:encode_pretty(data)
	end

return LfParser