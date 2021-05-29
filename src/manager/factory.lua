--- Factory manager.
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

local elements = { }
local cache = { }

local function isValidElement(obj)
	return type(obj) == 'table' and type(obj.name) == 'string' and type(obj.new) == 'function'
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

local Manager = { }

	--- Configure @{l2df.manager.factory|FactoryManager}.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt] string|{string,...} kwargs.scanpaths  Directory path or array of paths to @{Manager:scan|scan}.
	-- @return l2df.manager.factory
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		local ts = type(kwargs.scanpaths)
		if ts == 'string' then
			self:scan(kwargs.scanpaths)
		elseif ts == 'table' then
			for i = 1, #kwargs.scanpaths do
				self:scan(kwargs.scanpaths[i])
			end
		end
		return self
	end

	--- Create entity instance of the specified class.
	-- @param[opt] string|table class  Lower-case class name. If @{table} is passed instead of @{string},
	-- `class` argument would be skipped and passed @{table} would be used as `kwargs` argument.
	-- @param[opt] string|table kwargs  Could be a @{string} containing path to the `.dat` file to
	-- @{l2df.class.parser.parseFile|parse} or a @{table} with keyword arguments that would be passed to the
	-- creating @{Manager:add|object} constructor.
	-- @param[opt] ... ...  Would be passed to @{l2df.class.entity.new|Entity:new()} after `kwargs` array-part elements.
	-- @return l2df.class.entity
	function Manager:create(class, kwargs, ...)
		local file_path = false
		if type(class) == 'table' then
			class[#class + 1] = kwargs
			kwargs, class = class, 0
		else
			class = class and strlower(class) or 0
		end
		if kwargs then
			if type(kwargs) == 'string' then
				file_path = kwargs
				if cache[file_path] then
					return cache[file_path]:clone()
				end
				kwargs = parser:parseFile(file_path) or { }
			end
			local n = #kwargs
			for i = 1, select("#", ...) do
				kwargs[n + i] = select(i, ...)
			end
			kwargs = recursiveCreate(kwargs)
			if not elements[class] or kwargs.isInstanceOf then
				return kwargs
			end
			cache[file_path] = file_path and elements[class]:new(kwargs, unpack(kwargs))
			return file_path and cache[file_path]:clone() or elements[class]:new(kwargs, unpack(kwargs))
		end
		return elements[class] and elements[class]:new() or nil
	end

	--- Method for loading markup elements' classes.
	-- @param string path  Path to the folder containing files with `.lua` or `.dat` extension.
	-- For more information see @{l2df.helper.requireFolder|helper.requireFolder(path)} function.
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

	--- Method for adding new element to factory's engine.
	-- @param table|l2df.class.entity element  It could be both an @{l2df.class.entity|entity} class or @{table}
	-- containing `table.name` @{string} field and `table:new(kwargs, ...)` constructor.
	-- @return boolean  `true` if the specified `element` is valid and `false` otherwise.
	function Manager:add(element)
		if isValidElement(element) then
			elements[strlower(element.name)] = element
			return true
		end
		return false
	end

return setmetatable(Manager, { __call = Manager.init })