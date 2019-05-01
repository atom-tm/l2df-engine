local strsub = string.sub
local strfind = string.find
local strgmatch = string.gmatch

local DatParser = require "libs.parsers.dat"
local LfParser = DatParser:extend()

	LfParser.ARRAY_LBRACKET = "["
	LfParser.ARRAY_RBRACKET = "]"
	LfParser.BLOCK_LBRACKET = "{"
	LfParser.BLOCK_RBRACKET = "}"
	LfParser.VALUE_END_PATTERN = "[};,%s]"

	--- Method for parsing lf2 formatted string.
	-- You can extend existing object by passing it as second parameter.
	-- @param str, string  String for parsing
	-- @param obj, table   Object to extend, optional.
	-- @return table
	function LfParser:parse(str, obj)
		assert(type(str) == "string", "Parameter 'str' must be a string.")

		local result = obj or { }
		for key, content in strgmatch(str, "<([%w_]+)>([^<>]*)</[%w_]+>") do
			if key == "frame" then
				local from, to, id, name = strfind(content, "(%d+)%s+([%w_]+)")
				if not result.frames or type(result.frames) ~= "table" then
					result.frames = { }
				end
				local frames_count = #result.frames + 1
				result.frames[frames_count] = self:parseBlock( strsub(content, (to or 0) + 1, -1) )
				result.frames[frames_count].__internal = { id, name }
			else
				result[key] = self:parseBlock(content, result[key])
			end
		end

		return result
	end

	--- Method for dumping table to lf2 format
	-- @param str, string  String for parsing
	-- @return string
	function LfParser:dump(data)
		assert(type(str) == "table", "Parameter 'str' must be a table.")
		return ""
	end

return LfParser