--- Parser for LittleFighterForever syntax 2
-- @classmod l2df.class.parser.lffs2
-- @author Kasai
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'LffsParser works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local BaseParser = core.import 'class.parser'

local type = _G.type
local next = _G.next
local assert = _G.assert
local tonumber = _G.tonumber
local strsub = string.sub
local strbyte = string.byte
local strjoin = table.concat
local strfind = string.find
local strlower = string.lower
local strmatch = string.match
local plural = helper.plural

local LffsParser = BaseParser:extend()

	LffsParser.ARRAY_LBRACKET = strbyte('<')
	LffsParser.ARRAY_RBRACKET = strbyte('>')
	LffsParser.BLOCK_LBRACKET = strbyte('[')
	LffsParser.BLOCK_RBRACKET = strbyte(']')
	LffsParser.PARAM_SYMBOL = strbyte(':')
	LffsParser.QUOTE_SYMBOL = strbyte('"')
	LffsParser.CLOSE_SYMBOL = strbyte('/')
	LffsParser.VALUE_END_PATTERN = '[;,%s]'
	LffsParser.BLOCK_PATTERN = '([%w_]+)%s*:?%s*([%w_]-)'

	--- Method for parsing lffs formatted string
	-- You can extend existing object by passing it as second parameter
	-- @param string str  String for parsing
	-- @param table obj   Object to extend, optional
	-- @return table
	function LffsParser:parse(str, obj)
		assert(type(str) == 'string', 'Parameter "str" must be a string.')

		local result = obj or { }
		local stack = { result }
		local is_array = { false }
		local head = 1
		local param = nil
		local token = nil
		local plural_token = nil
		local parent = nil
		local foobar = nil
		local char = nil
		local byte = nil
		local pos = 0
		local len = #str

		local buffer = { }
		local bufsize = 0
		local oldsize = 0
		local ending = nil
		local prune_param = false
		local is_param = false
		local is_string = false
		local is_concat = false

		while pos < len do
			while pos < len do
				pos = pos + 1
				byte = strbyte(str, pos)

				if not is_concat then
					-- Previous token was param
					if byte == self.PARAM_SYMBOL then
						is_param = true
						if is_array[head] then
							is_array[head] = false
							if bufsize == 0 then
								foobar = stack[head]
								foobar[#foobar] = nil
							end
							if param then
								head = head - 1
							end
						end
						break

					-- Start collecting quoted string
					elseif byte == self.QUOTE_SYMBOL then
						is_concat = self.QUOTE_SYMBOL
						is_string = true
						break

					-- Create object block
					elseif byte == self.BLOCK_RBRACKET then
						parent = stack[head]
						head = head + 1
						foobar = parent[token] or { }
						parent[token] = foobar
						stack[head] = foobar
						is_array[head] = true
						break

					-- Create / append array block
					elseif byte == self.ARRAY_RBRACKET then
						plural_token = token .. 's'
						-- plural_token = plural(token)
						parent = stack[head]
						foobar = parent[plural_token] or { }
						parent[plural_token] = foobar

						parent = foobar
						foobar = { }
						parent[#parent + 1] = foobar
						head = head + 1
						stack[head] = foobar
						is_array[head] = true
						break

					-- Start collecting block's caption / close block
					elseif byte == self.BLOCK_LBRACKET then
						ending = self.BLOCK_RBRACKET
						break

					-- Start collecting array's item's caption / close item
					elseif byte == self.ARRAY_LBRACKET then
						ending = self.ARRAY_RBRACKET
						break
					end

				-- Stop concating
				elseif byte == is_concat then
					if byte ~= self.QUOTE_SYMBOL then
						pos = pos - 1
					end
					is_concat = false
					is_string = false
					break
				end

				-- Collecting token
				char = strsub(str, pos, pos)
				if strmatch(char, self.VALUE_END_PATTERN) and not is_concat then
					break
				else
					bufsize = bufsize + 1
					buffer[bufsize] = char
				end
			end -- while

			if bufsize > 0 then
				-- Prune buffer
				for j = oldsize, bufsize + 1, -1 do
					buffer[j] = nil
				end
				oldsize = bufsize
				bufsize = 0

				-- Get token
				token = strjoin(buffer)
				if not is_string then
					token = self:parseScalar(token)
				end

				-- Param key token
				if is_param then
					-- pass

				-- Array value token
				elseif is_array[head] then
					parent = stack[head]
					parent[#parent + 1] = token

				-- Param value token
				elseif param then
					parent = stack[head]
					if parent[param] then
						head = head + 1
						foobar = { parent[param], token }
						parent[param] = foobar
						stack[head] = foobar
						is_array[head] = true
					else
						parent[param] = token
					end
				end
			end -- if buffer

			-- Handle blocks' start
			if ending then
				foobar = is_array[head]
				is_array[head] = false
				if param and foobar then
					head = head - 1
				end
				if strbyte(str, pos + 1) == self.CLOSE_SYMBOL then
					pos = pos + 1
					while pos < len and strbyte(str, pos) ~= ending do
						pos = pos + 1
					end
					head = head - 1
				else
					is_concat = ending
				end
				param = nil
				ending = nil

			elseif is_param then
				param = token
				is_param = false
			end -- if param
		end -- while

		return result
	end

	--- Method for dumping table to lffs format
	-- @param table data  Table for dumping
	-- @return string
	function LffsParser:dump(data)
		assert(type(data) == 'table', 'Parameter "data" must be a table.')
		return ''
	end

return LffsParser