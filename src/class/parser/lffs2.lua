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
local pairs = _G.pairs
local assert = _G.assert
local tonumber = _G.tonumber
local tostring = _G.tostring
local strrep = string.rep
local strsub = string.sub
local strbyte = string.byte
local strjoin = table.concat
local strfind = string.find
local strlower = string.lower
local strmatch = string.match
local strformat = string.format
local plural = helper.plural
local singular = helper.singular
local isArray = helper.isArray

local LffsParser = BaseParser:extend()

	LffsParser.COMMENT_SYMBOL = '#'
	LffsParser.PARAM_SYMBOL = ':'
	LffsParser.QUOTE_SYMBOL = '"'
	LffsParser.CLOSE_SYMBOL = strbyte('/')
	LffsParser.ARRAY_RBRACKETB = strbyte('>')
	LffsParser.BLOCK_RBRACKETB = strbyte(']')
	LffsParser.ARRAY_LBRACKET = '<'
	LffsParser.ARRAY_RBRACKET = '>'
	LffsParser.BLOCK_LBRACKET = '['
	LffsParser.BLOCK_RBRACKET = ']'
	LffsParser.VALUE_END_PATTERN = '[;,%s]'
	LffsParser.BLOCK_PATTERN = '([%w_]+):?([%w_]*)'

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
		local pname = nil
		local ptype = nil
		local token = nil
		local parent = nil
		local foobar = nil
		local prev = nil
		local char = nil
		local byte = nil
		local pos = 0
		local len = #str

		local buffer = { }
		local bufsize = 0
		local oldsize = 0
		local ending = nil
		local ending_byte = nil
		local prune_param = false
		local is_param = false
		local is_string = false
		local is_concat = false
		local is_comment = false

		while pos < len do
			while pos < len do
				pos = pos + 1
				prev, char = char, strsub(str, pos, pos)

				if not is_concat then
					-- Previous token was param
					if char == self.PARAM_SYMBOL then
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

					-- Skip the rest of the line if comment was met
					elseif char == self.COMMENT_SYMBOL and (not prev or strmatch(prev, self.VALUE_END_PATTERN)) then
						is_concat = '\n'
						is_comment = true
						break

					-- Start collecting quoted string
					elseif char == self.QUOTE_SYMBOL then
						is_concat = self.QUOTE_SYMBOL
						is_string = true
						break

					-- Create object block
					elseif char == self.BLOCK_RBRACKET then
						pname, ptype = strmatch(token, self.BLOCK_PATTERN)
						parent = stack[head]
						head = head + 1
						foobar = parent[pname] or { }
						foobar._type = ptype ~= '' and ptype or nil
						parent[pname] = foobar
						stack[head] = foobar
						is_array[head] = true
						break

					-- Create / append array block
					elseif char == self.ARRAY_RBRACKET then
						pname, ptype = strmatch(token, self.BLOCK_PATTERN)
						pname = plural(pname)
						parent = stack[head]
						foobar = parent[pname] or { }
						parent[pname] = foobar

						parent = foobar
						foobar = ptype ~= '' and { _type = ptype } or { }
						parent[#parent + 1] = foobar
						head = head + 1
						stack[head] = foobar
						is_array[head] = true
						break

					-- Start collecting block's caption / close block
					elseif char == self.BLOCK_LBRACKET then
						ending = self.BLOCK_RBRACKET
						ending_byte = self.BLOCK_RBRACKETB
						break

					-- Start collecting array's item's caption / close item
					elseif char == self.ARRAY_LBRACKET then
						ending = self.ARRAY_RBRACKET
						ending_byte = self.ARRAY_RBRACKETB
						break
					end

				-- Stop concating
				elseif char == is_concat then
					if char ~= self.QUOTE_SYMBOL then
						pos = pos - 1
					end
					is_concat = false
					is_string = false
					is_comment = false
					break
				end

				-- Collecting token
				if not is_concat and strmatch(char, self.VALUE_END_PATTERN) then
					break
				elseif not is_comment then
					bufsize = bufsize + 1
					buffer[bufsize] = char
				end
			end -- while

			-- Fetch token from buffer and process it
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
					while pos < len and strbyte(str, pos) ~= ending_byte do
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
	function LffsParser:dump(data, offset)		
		offset = offset or 0
		local tv = type(data)
		if tv ~= 'table' then
			return strformat(tv == 'string' and ' "%s"' or ' %s', tostring(data)), false
		end
		local head, j, is_array = { }, 1, true
		local tab = strrep(' ', 4 * offset)
		for k = 1, #data do
			local tv = type(data[k])
			if tv ~= 'table' then
				head[j] = strformat(tv == 'string' and ' "%s"' or ' %s', tostring(data[k]))
				j = j + 1
			end
		end
		local head, body, i, j = { strjoin(head) }, { }, 1, 2
		for k, v in pairs(data) do
			local tk, tv = type(k), type(v)
			if tk == 'number' and tv ~= 'table' or tk == 'table' or k == '_type' then
				-- skip
			elseif isArray(v) and type(v[1]) == 'table' then
				is_array = false
				k = singular(k)
				body[i], i = ' ', i + 1
				for l = 1, #v do
					local r, isarr = self:dump(v[l], offset + 1)
					local t = v[l]._type or (v[l].___class and v[l].name) or nil
                    body[i] = strformat('%s<%s%s>%s%s</%s>', tab, k, t and (':'..t) or '', r, isarr and ' ' or ('\n'..tab), k)
                    i = i + 1
				end
			else
				is_array = false
				local r, isarr = self:dump(v, offset + 1)
				if isarr or tv ~= 'table' then
					head[j] = strformat('%s%s:%s', tab, k, r)
					j = j + 1
				else
					local t = v._type or (v.___class and v.name) or nil
					body[i] = strformat('\n%s[%s%s]%s\n%s[/%s]', tab, k, t and (':'..t) or '', r, tab, k)
					i = i + 1
				end
			end
		end
		return strformat('%s%s%s', strjoin(head, '\n'), #head > 1 and #body > 0 and '\n' or '', strjoin(body, '\n')), is_array
	end

return LffsParser