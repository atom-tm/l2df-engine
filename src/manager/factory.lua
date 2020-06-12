--- Factory manager
-- @classmod l2df.manager.factory
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'FactoryManager works only with l2df v1.0 and higher')

local parser = core.import 'class.parser.lffs2'
local helper = core.import 'helper'

local fs = love and love.filesystem
local requireFolder = helper.requireFolder
local isArray = helper.isArray
local strlower = string.lower
local type = _G.type
local pairs = _G.pairs
local unpack = _G.unpack or table.unpack

local Manager = { }

	local elements = { }
	local cache = { }

	local function isValidElement(obj)
		return type(obj) == 'table' and type(obj.name) == 'string' and type(obj.__call) == 'function'
	end

	function Manager:getList()
		for key, val in pairs(elements) do
			print(key)
		end
	end

	local function recursiveCreate(kwargs)
		local obj = { }
		for k, v in pairs(kwargs) do
			obj[k] = type(v) == 'table' and recursiveCreate(v) or v
		end
		if obj._type and elements[obj._type] then
			obj = elements[obj._type]:new(obj, unpack(obj))
		end
		return obj
	end

	---
	-- @param string class
	-- @param string|table kwargs
	function Manager:create(class, kwargs)
		local filePath = false
		class = class and strlower(class) or 0
		if kwargs then
			if type(kwargs) == 'string' then
				filePath = kwargs
				if cache[filePath] then
					return cache[filePath]:clone()
				end
				kwargs = parser:parseFile(kwargs) or { }
			end
			kwargs = recursiveCreate(kwargs)
			if not elements[class] then
				return kwargs
			end
			cache[filePath] = filePath and elements[class]:new(kwargs, unpack(kwargs))
			return filePath and cache[filePath]:clone() or elements[class]:new(kwargs, unpack(kwargs))
		end
		return elements[class] and elements[class]:new() or nil
	end

	--- Method for loading markup elements' classes
	-- @param string path  Path
	function Manager:scan(path)
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

	--- Method for adding new element to factory's engine
	-- @param table element
	-- @return boolean
	function Manager:add(element)
		if isValidElement(element) then
			elements[strlower(element.name)] = element
			return true
		end
		return false
	end

return Manager
