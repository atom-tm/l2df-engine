local __DIR__ = (...):match('(.-)[^%.]+%.[^%.]+$')

local helper = require(__DIR__ .. 'helper')
local DatParser = require(__DIR__ .. 'parsers.dat')

local strsub = string.sub
local strfind = string.find
local strlower = string.lower
local strgmatch = string.gmatch
local requireFolder = helper.requireFolder
local isArray = helper.isArray

local LffParser = DatParser:extend()

	local elements = { }

	local function isValidElement(obj)
		return type(obj) == 'table' and type(obj.name) == 'string' and type(obj.__call) == 'function'
	end

	function helper.requireFolder(folderpath, keys, pattern)
		local result = { }
		if fs and folderpath and fs.getInfo(folderpath, 'directory') then
			folderpath = folderpath:find('/$') and folderpath or folderpath .. '/'

			local modulepath = folderpath:gsub('/', '.')
			local id, file
			local files = fs.getDirectoryItems(folderpath)

			for i = 1, #files do
				if (not pattern or files[i]:find(pattern)) and files[i]:find('.lua$') then
					file = files[i]:gsub('.lua$', '')
					id = keys and file or #result + 1
					result[id] = require(modulepath .. file)
				end
			end
		end
		return result
	end
	LffParser.elements = elements

	LffParser.ARRAY_LBRACKET = '['
	LffParser.ARRAY_RBRACKET = ']'
	LffParser.BLOCK_LBRACKET = '{'
	LffParser.BLOCK_RBRACKET = '}'
	LffParser.VALUE_END_PATTERN = '[;,%s]'
	LffParser.BLOCK_PATTERN = '(</?([%w_]+)>)' --'<([%w_]+)>([^<>]*)</[%w_]+>'
	LffParser.ARGS_PATTERN = '([^<:>])'

	--- Method for parsing lf2 formatted string.
	-- You can extend existing object by passing it as second parameter.
	-- @param string str  String for parsing
	-- @param table obj   Object to extend, optional.
	-- @return table
	function LffParser:parse(str, obj)
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
					self:parseBlock(strsub(str, bpos, from - 1), stack[head])
					head = head + 1
					stack[head] = { nodes = { } }
					tags[head] = param
				elseif head > 1 and tags[head] == param then -- close
					self:parseBlock(strsub(str, bpos, from - 1), stack[head])
					head = head - 1
					node = stack[head]
					node.nodes[#node.nodes + 1] = elements[param](stack[head + 1])
				end
				pos = pos + 1
			end -- if
		end -- while

		-- Parse the rest of input
		if bpos < len then
			self:parseBlock(strsub(str, bpos, -1), result)
		end

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

	--- Method for loading markup elements' classes
	-- @param string path  Path
	function LffParser:scan(path)
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

	---
	function LffParser:add(element)
		if isValidElement(element) then
			elements[strlower(element.name)] = element
			return true
		end
		return false
	end

	--- Method for dumping table to lf2 format
	-- @param table data  Table for dumping
	-- @return string
	function LffParser:dump(data)
		assert(type(data) == 'table', 'Parameter "data" must be a table.')
		return ''
	end

return LffParser