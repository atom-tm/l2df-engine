local strfind = string.find
local strsub = string.sub
local strmatch = string.match

local BaseParser = require("libs.parsers.base")
local DatParser = BaseParser:extend()

	function DatParser.parseFile(filepath)
		assert(type(filepath) == "string", "Parameter 'filepath' must be a string.")
		if love then
			return DatParser.parse( love.filesystem.read(filepath) )
		end
		return nil
	end

	function DatParser.parse(str)
		assert(type(str) == "string", "Parameter 'str' must be a string.")

		local result = { }
		local key = nil
		local section = "global"
		local len = #str
		local from = 1
		local pos = 1
		local to = 1

		while section do
			to, pos, key = strfind(str, "%[%s*(%w+)%s*%]", pos)
			result[section] = DatParser.parseBlock( str:sub(from, (to or len + 1) - 1) )
			section = key
			from = (pos or 0) + 1
		end

		return result
	end

	function DatParser.dump(data)
		assert(type(str) == "table", "Parameter 'str' must be a table.")
		return ""
	end

	function DatParser.parseBlock(str)
		str = (str or "") .. " "

		local result = { }
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
			from, pos, param = strfind(str, "(%w+)%s*:%s*", pos)
			if not param then break end

			if head > 1 then
				bpos = strfind(str, "]", bpos)
				if bpos and bpos < from then
					head = head - 1
				end
			end

			local value = ""
			local is_quoted = false

			while pos < len do
				pos = pos + 1
				char = strsub(str, pos, pos)

				if char == "[" then
					stack[head][param] = { }
					stack[head + 1] = stack[head][param]
					head = head + 1
					break

				elseif char == "{" then
					stack[head][param] = { }

				elseif char == "}" then
					break

				elseif char == "\"" and not is_quoted then
					is_quoted = true

				elseif strmatch(char, "[%];,%s]") and not is_quoted or char == "\"" then
					local x = stack[head][param]
					if x and type(x) == "table" then
						x[#x + 1] = DatParser.parseScalar(value)
					else
						stack[head][param] = DatParser.parseScalar(value)
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