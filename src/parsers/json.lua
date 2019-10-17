--- Parser for JSON syntax
-- @classmod l2df.parsers.json
-- @author Abelidze
-- @copyright Atom-TM 2019

local __DIR__ = (...):match('(.-)[^%.]+%.[^%.]+$')

local json = require(__DIR__ .. 'external.json')
local BaseParser = require(__DIR__ .. 'parsers.base')

local JsonParser = BaseParser:extend()

	--- Method for parsing json formatted string
	-- @param string str  String for parsing
	-- @return table
	function JsonParser:parse(str)
		assert(type(str) == 'string', 'Parameter "str" must be a string.')
		return json:decode(str)
	end

	--- Method for dumping table to json format
	-- @param table data  Table for dumping
	-- @return string
	function JsonParser:dump(data)
		assert(type(data) == 'table', 'Parameter "data" must be a table.')
		return json:encode_pretty(data)
	end

return JsonParser