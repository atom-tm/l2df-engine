local strmatch = string.match

local Object = require("libs.object")
local Parser = Object:extend()

	function Parser:init()
		-- pass
	end

	function Parser.parseFile(filepath)
		assert(type(filepath) == "string", "Parameter 'filepath' must be a string.")
		return nil
	end

	function Parser.parse(str)
		assert(type(str) == "string", "Parameter 'str' must be a string.")
		return nil
	end

	function Parser.parseScalar(str)
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

	function Parser.dump(data)
		assert(type(str) == "table", "Parameter 'str' must be a table.")
		return tostring(data)
	end

return Parser