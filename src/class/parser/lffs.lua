--- Parser for LittleFighterForever syntax
-- @classmod l2df.class.parser.lffs
-- @author Abelidze
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'JsonParser works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local DatParser = core.import 'class.parser.dat'

local strsub = string.sub
local strjoin = table.concat
local strfind = string.find
local strlower = string.lower
local strmatch = string.match
local strgmatch = string.gmatch
local unpack = unpack or table.unpack
local requireFolder = helper.requireFolder
local isArray = helper.isArray

local LffsParser = DatParser:extend()

	local elements = { }

	local function isValidElement(obj)
		return type(obj) == 'table' and type(obj.name) == 'string' and type(obj.__call) == 'function'
	end

	LffsParser.ARRAY_LBRACKET = '['
	LffsParser.ARRAY_RBRACKET = ']'
	LffsParser.BLOCK_LBRACKET = '{'
	LffsParser.BLOCK_RBRACKET = '}'
	LffsParser.VALUE_END_PATTERN = '[;,%s]'
	LffsParser.BLOCK_PATTERN = '(</?([%w_]+)>)'
	--'(</?([%w_]+)%s*#?%s*([%w_]-)>)'
	--'<([%w_]+)>([^<>]*)</[%w_]+>'
	LffsParser.ARGS_PATTERN = '([^<:>])'

	--- Method for parsing lffs formatted string
	-- You can extend existing object by passing it as second parameter
	-- @param string str  String for parsing
	-- @param table obj   Object to extend, optional
	-- @return table
	function LffsParser:parse(str, obj)
		assert(type(str) == 'string', 'Parameter "str" must be a string.')

		local result = obj or { nodes = { } }
		if strgmatch(str, self.BLOCK_PATTERN)() == nil then
			return self:parseBlock(str, result)
		end

		local stack = { result }
		local tags = { '_root' }
		local head = 1
		local from = 1
		local bpos = 1
		local pos = 1
		local len = #str
		local param = nil
		local node = nil
		local args = nil

		-- Parse blocks
		while pos and pos < len do
			bpos = pos
			from, pos, tag, param = strfind(str, self.BLOCK_PATTERN, pos)

			if param then
				param = strlower(param)
				if not elements[param] then
					error('ParserError: "<' .. param .. '>" is unknown type')
				end
				if not strfind(tag, '^</') then -- open
					args, bpos = self:parseArguments(str, bpos, from - 1)
					if not stack[head]._args then
						stack[head]._args = args
					end
					self:parseBlock(strsub(str, bpos, from - 1), stack[head])

					head = head + 1
					stack[head] = { nodes = { } }
					tags[head] = param
				elseif head > 1 and tags[head] == param then -- close
					args = stack[head]._args
					if not args then
						args, bpos = self:parseArguments(str, bpos, from - 1)
					end
					self:parseBlock(strsub(str, bpos, from - 1), stack[head])

					head = head - 1
					node = stack[head]
					node.nodes[#node.nodes + 1] = elements[param](stack[head + 1], unpack(args))
				end
				pos = pos + 1
			end -- if
		end -- while

		-- Parse the rest of input
		if bpos < len then
			self:parseBlock(strsub(str, bpos, -1), result)
		end
		result._args = nil

		-- Return result depending on its content
		if #result.nodes > 1 then
			return result
		end

		local key = next(result)
		if key and next(result, key) then
			return result
		end

		return result.nodes[1]
	end

	--- Method for parsing arguments from string on defined range
	-- @param string str
	-- @param number from
	-- @param number to
	-- @return table
	-- @return number
	function LffsParser:parseArguments(str, from, to)
		local result = { }
		local char = nil
		local is_string = false
		local buffer = { }
		local bufsize = 0
		local oldsize = 0
		local len = 0
		local pos = from

		for i = from, to do
			char = strsub(str, i, i)
			if char == '"' then -- string parser
				if is_string then
					-- Prune buffer
					for j = oldsize, bufsize, -1 do
						buffer[j] = nil
					end
					oldsize = bufsize
					bufsize = 0

					-- Append string to result
					pos = i + 1
					len = len + 1
					result[len] = strjoin(buffer)
					is_string = false
				else
					is_string = true
				end
			elseif strmatch(char, '%s') and not is_string then -- scalar parser
				if bufsize > 0 then
					-- Prune buffer
					for j = oldsize, bufsize + 1, -1 do
						buffer[j] = nil
					end
					oldsize = bufsize
					bufsize = 0

					-- Parse and append scalar to result
					pos = i + 1
					len = len + 1
					result[len] = self:parseScalar( strjoin(buffer) )
				end
			elseif char == ':' and not is_string then
				if bufsize == 0 then result[len] = nil end
				return result, pos
			else -- collecting chars into buffer
				if bufsize == 0 then pos = i end
				bufsize = bufsize + 1
				buffer[bufsize] = char
			end
		end
		return result, to + 1
	end

	--- Method for loading markup elements' classes
	-- @param string path  Path
	function LffsParser:scan(path)
		assert(type(path) == 'string', 'Parameter "path" must be a string.')

		local modules = requireFolder(path)
		for i = 1, #modules do
			local mod = modules[i]
			self:add(mod)
			if isArray(mod) then
				for j = 1, #mod do
					self:add(mod[j])
				end
			end
		end
	end

	--- Method for adding new element to parser's engine
	-- @param table element
	-- @return boolean
	function LffsParser:add(element)
		if isValidElement(element) then
			elements[strlower(element.name)] = element
			return true
		end
		return false
	end

	--- Method for dumping table to lffs format
	-- @param table data  Table for dumping
	-- @return string
	function LffsParser:dump(data)
		assert(type(data) == 'table', 'Parameter "data" must be a table.')
		return ''
	end

return LffsParser