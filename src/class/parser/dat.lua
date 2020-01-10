--- Parser for DAT syntax
-- @classmod l2df.class.parser.dat
-- @author Abelidze
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'DatParser works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local BaseParser = core.import 'class.parser'

local strsub = string.sub
local strfind = string.find
local strmatch = string.match
local strformat = string.format
local strjoin = table.concat
local plural = helper.plural

local DatParser = BaseParser:extend()

	DatParser.ARRAY_LBRACKET = '{'
	DatParser.ARRAY_RBRACKET = '}'
	DatParser.BLOCK_LBRACKET = '['
	DatParser.BLOCK_RBRACKET = ']'
	DatParser.VALUE_END_PATTERN = '[;,%s]'

	--- Method for parsing dat formatted string
	-- You can extend existing object by passing it as second parameter.
	-- @param string str  String for parsing
	-- @param table obj  Object to extend, optional.
	-- @return table
	function DatParser:parse(str, obj)
		assert(type(str) == 'string', 'Parameter "str" must be a string.')

		local result = obj or { }
		local key = nil
		local section = 'global'
		local len = #str
		local from = 1
		local pos = 1
		local to = 1

		while section do
			to, pos, key = strfind(str, '%[%s*(%w+)%s*%]', pos)
			result[section] = self:parseBlock(strsub(str, from, (to or len + 1) - 1), result[section])
			section = key
			from = (pos or 0) + 1
		end

		return result
	end

	--- Method for dumping table to dat format
	-- @param table data  Table for dumping
	-- @return string
	function DatParser:dump(data)
		assert(type(data) == 'table', 'Parameter "data" must be a table.')

		local result = self:dumpBlock(type(data.global) == 'table' and data.global or { })
		for section, block in pairs(data) do
			if type(block) == 'table' and section ~= 'global' and section ~= 'private' then
				result = strformat('%s\n[%s]\n%s', result, section, self:dumpBlock(block))
			end
		end
		return result
	end

	--- Method for dumping dat-file's block
	-- @param table block  Block for dumping
	-- @param[opt] string tabs
	-- @return string
	function DatParser:dumpBlock(block, tabs)
		tabs = tabs or ''

		local result = ''
		for key, param in pairs(block) do
			local t = type(param)
			if t == 'table' then
				local size = #param
				if size > 0 and param[size] and type(param[size]) ~= 'table' then
					result = strformat('%s%s%s: { %s }\n', result, tabs, key, strjoin(param))
				else
					result = strformat('%s%s%s: [\n%s]\n', result, tabs, key, self:dumpBlock(param, tabs .. "\t"), tabs)
				end
			elseif t ~= 'function' then
				result = strformat('%s%s%s: %s\n', result, tabs, key, self:dumpScalar(param))
			end
		end
		return result
	end

	--- Method for parsing dat-file's section string
	-- You can extend existing object by passing it as second parameter.
	-- @param string str  String for parsing
	-- @param table obj  Object to extend, optional.
	-- @return table
	function DatParser:parseBlock(str, obj)
		str = (str or '') .. ' '

		local result = obj or { }
		local stack = { result }
		local is_array = { false }
		local head = 1
		local param = nil
		local plural_param = nil
		local parent = nil
		local char = nil
		local from = 1
		local pos = 1
		local bpos = 1
		local len = #str

		while pos < len do
			if is_array[head] then
				param = #stack[head] + 1
			else
				bpos = pos
				from, pos, param = strfind(str, '([%w_]+)%s*:%s*', pos)
				if not param then break end
				param = tonumber(param) or param

				if head > 1 then
					bpos = strfind(str, self.BLOCK_RBRACKET, bpos)
					if bpos and bpos < from then
						head = head - 1
						if is_array[head] then
							pos = bpos
							param = #stack[head] + 1
						end
					end
				end
			end

			local value = { }
			local is_quoted = false

			while pos < len do
				pos = pos + 1
				char = strsub(str, pos, pos)

				if char == self.BLOCK_LBRACKET then
					parent = stack[head]
					head = head + 1
					is_array[head] = false
					if is_array[head - 1] then
						stack[head] = { }
					else
						stack[head] = parent[param] or { }
					end
					plural_param = plural(param)
					if parent[plural_param] then
						parent[plural_param][#parent[plural_param] + 1] = stack[head]
					elseif parent[param] then
						parent[plural_param] = { parent[param], stack[head] }
						parent[param] = nil
					else
						parent[param] = stack[head]
					end
					break

				elseif char == self.ARRAY_LBRACKET then
					parent = stack[head]
					head = head + 1
					is_array[head] = true
					stack[head] = { }
					plural_param = plural(param)
					if parent[plural_param] then
						parent[plural_param][#parent[plural_param] + 1] = stack[head]
					elseif parent[param] then
						parent[plural_param] = { parent[param], stack[head] }
						parent[param] = nil
					else
						parent[param] = stack[head]
					end
					param = 1

				elseif char == self.ARRAY_RBRACKET then
					if is_array[head] then
						if next(value) then
							stack[head][param] = self:parseScalar(strjoin(value))
						end
						is_array[head] = false
						head = head - 1
					end
					break

				elseif char == '\"' and not is_quoted then
					is_quoted = true

				elseif strmatch(char, self.VALUE_END_PATTERN) and not is_quoted or char == '\"' then
					if is_array[head] then
						if next(value) then
							stack[head][param] = self:parseScalar(strjoin(value))
							param = param + 1
						end
					else
						parent = stack[head]
						plural_param = plural(param)
						if parent[plural_param] then
							parent[plural_param][#parent[plural_param] + 1] = self:parseScalar(strjoin(value))
						elseif parent[param] then
							parent[plural_param] = { parent[param], self:parseScalar(strjoin(value)) }
							parent[param] = nil
						else
							parent[param] = self:parseScalar(strjoin(value))
						end
						break
					end
					value = { }

				else
					value[#value + 1] = char

				end
			end -- while
		end -- while true

		return result
	end

return DatParser