local __DIR__ = (...):match("(.-)[^%.]+%.[^%.]+$")

local strsub = string.sub
local strfind = string.find
local strgmatch = string.gmatch

local DatParser = require(__DIR__ .. "parsers.dat")

local LfParser = DatParser:extend()

	LfParser.ARRAY_LBRACKET = "["
	LfParser.ARRAY_RBRACKET = "]"
	LfParser.BLOCK_LBRACKET = "{"
	LfParser.BLOCK_RBRACKET = "}"
	LfParser.VALUE_END_PATTERN = "[;,%s]"
	LfParser.BLOCK_PATTERN = "<([%w_]+)>([^<>]*)</[%w_]+>"

	--- Method for parsing lf2 formatted string.
	-- You can extend existing object by passing it as second parameter.
	-- @param str, string  String for parsing
	-- @param obj, table   Object to extend, optional.
	-- @return table
	function LfParser:parse(str, obj)
		assert(type(str) == "string", "Parameter 'str' must be a string.")

		local result = obj or { }
		if strgmatch(str, self.BLOCK_PATTERN)() == nil then
			return self:parseBlock(str, result)
		end

		if type(result.frames) ~= "table" then
			result.frames = { }
		end
		if type(result.frames_list) ~= "table" then
			result.frames_list = { }
		end

		for key, content in strgmatch(str, self.BLOCK_PATTERN) do
			if key == "frame" then
				local from, to, id, name = strfind(content, "(%d+)%s+([%w_]*)")
				local frames_count = #result.frames + 1
				id = tonumber(id) or id
				result.frames[id] = self:parseBlock( strsub(content, (to or 0) + 1, -1) )
				result.frames[id].name = name
			else
				result[key] = self:parseBlock(content, result[key])
			end
		end

		local list = nil
		for id, frame in pairs(result.frames) do
			if frame.name and #frame.name > 0 then
				list = result.frames_list[frame.name]
				if type(list) == "table" then
					list[#list + 1] = id
				elseif not list then
					result.frames_list[frame.name] = id
				end
			end
		end

		return result
	end

	--- Method for dumping table to lf2 format
	-- @param data, table  Table for dumping
	-- @return string
	function LfParser:dump(data)
		assert(type(data) == "table", "Parameter 'data' must be a table.")
		return ""
	end

return LfParser