local __DIR__ = (...):match("(.-)[^%.]+%.[^%.]+$")

local strfind = string.find
local strsub = string.sub
local strmatch = string.match
local strformat = string.format
local strjoin = table.concat

local BaseParser = require(__DIR__ .. "parsers.base")

local DatParser = BaseParser:extend()

	DatParser.ARRAY_LBRACKET = "{"
	DatParser.ARRAY_RBRACKET = "}"
	DatParser.BLOCK_LBRACKET = "["
	DatParser.BLOCK_RBRACKET = "]"
	DatParser.VALUE_END_PATTERN = "[%];,%s]"

	--- Method for parsing dat formatted string
	-- You can extend existing object by passing it as second parameter.
	-- @param str, string  String for parsing
	-- @param obj, table   Object to extend, optional.
	-- @return table
	function DatParser:parse(str, obj)
		assert(type(str) == "string", "Parameter 'str' must be a string.")

		local result = obj or { }
		local key = nil
		local section = "global"
		local len = #str
		local from = 1
		local pos = 1
		local to = 1

		while section do
			to, pos, key = strfind(str, "%[%s*(%w+)%s*%]", pos)
			result[section] = self:parseBlock(strsub(str, from, (to or len + 1) - 1), result[section])
			section = key
			from = (pos or 0) + 1
		end

		return result
	end

	--- Method for dumping table to dat format
	-- @param data, table  Table for dumping
	-- @return string
	function DatParser:dump(data)
		assert(type(data) == "table", "Parameter 'data' must be a table.")

		local result = self:dumpBlock(type(data.global) == "table" and data.global or { })
		for section, block in pairs(data) do
			if type(block) == "table" and section ~= "global" and section ~= "private" then
				result = strformat("%s\n[%s]\n%s", result, section, self:dumpBlock(block))
			end
		end
		return result
	end

	--- Method for dumping dat-file's block
	-- @param block, table  Block for dumping.
	-- @return string
	function DatParser:dumpBlock(block, tabs)
		tabs = tabs or ""

		local result = ""
		for key, param in pairs(block) do
			local t = type(param)
			if t == "table" then
				local size = #param
				if size > 0 and param[size] and type(param[size]) ~= "table" then
					result = strformat("%s%s%s: { %s }\n", result, tabs, key, strjoin(param))
				else
					result = strformat("%s%s%s: [\n%s]\n", result, tabs, key, self:dumpBlock(param, tabs .. "\t"), tabs)
				end
			elseif t ~= "function" then
				result = strformat("%s%s%s: %s\n", result, tabs, key, self:dumpScalar(param))
			end
		end
		return result
	end

	--- Method for parsing dat-file's section string
	-- You can extend existing object by passing it as second parameter.
	-- @param str, string  String for parsing
	-- @param obj, table   Object to extend, optional.
	-- @return table
	function DatParser:parseBlock(str, obj)
		str = (str or "") .. " "

		local result = obj or { }
		local stack = { result }
		local head = 1
		local param = nil
		local char = nil
		local from = 1
		local pos = 1
		local bpos = 1
		local len = #str

		while true do
			bpos = pos
			from, pos, param = strfind(str, "([%w_]+)%s*:%s*", pos)
			if not param then break end
			param = tonumber(param) or param

			if head > 1 then
				bpos = strfind(str, self.BLOCK_RBRACKET, bpos)
				if bpos and bpos < from then
					head = head - 1
				end
			end

			local value = ""
			local is_quoted = false

			while pos < len do
				pos = pos + 1
				char = strsub(str, pos, pos)

				if char == self.BLOCK_LBRACKET then
					stack[head][param] = stack[head][param] or { }
					stack[head + 1] = stack[head][param]
					head = head + 1
					break

				elseif char == self.ARRAY_LBRACKET then
					stack[head][param] = { }

				elseif char == self.ARRAY_RBRACKET then
					break

				elseif char == "\"" and not is_quoted then
					is_quoted = true

				elseif strmatch(char, self.VALUE_END_PATTERN) and not is_quoted or char == "\"" then
					local x = stack[head][param]
					if x and type(x) == "table" then
						if value ~= "" then
							x[#x + 1] = self:parseScalar(value)
						end
					else
						stack[head][param] = self:parseScalar(value)
						break
					end
					value = ""

				else
					value = value .. char

				end
			end -- while
		end -- while true

		return result
	end

return DatParser