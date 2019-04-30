local json = require "libs.external.json"
local BaseParser = require "libs.parsers.base"
local JsonParser = BaseParser:extend()


	--- Method for parsing json formatted string
	-- @param str, string  String for parsing
	-- @return table
	function JsonParser:parse(str)
		assert(type(str) == "string", "Parameter 'str' must be a string.")
		return json:decode(str)
	end

	--- Method for dumping table to json format
	-- @param str, string  String for parsing
	-- @return string
	function JsonParser:dump(data)
		assert(type(str) == "table", "Parameter 'str' must be a table.")
		return json:encode_pretty(data)
	end

return JsonParser