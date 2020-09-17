--- Configs and settings
-- @module l2df.config
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)[^%.]+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Config works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local Parser = core.import 'class.parser.lffs2'

local type = _G.type
local pairs = _G.pairs
local select = _G.select
local strgmatch = string.gmatch
local copy = helper.copyTable

local config = { }
local groups = { }

local Module = { }

	---
	-- @param[opt] string group
	-- @return table
	function Module:all(group)
		local g = group and groups[group] or nil
		if not g then
			return config
		end
		local data = { }
		for i = 1, #g do
			data[g[i]] = config[g[i]]
		end
		return data
	end

	---
	-- @param string group
	-- @param {string, ...} ...
	function Module:group(group, ...)
		local data = groups[group] or { }
		for i = 1, select('#', ...) do
			data[#data + 1] = select(i, ...)
		end
		groups[group] = data
	end

	---
	-- @param string key
	-- @return mixed
	function Module:get(key)
		key = type(key) == 'string' and key or ''
		local result
		for k in strgmatch(key, '[^%.]+') do
			result = result and result[k] or config[k]
		end
		return result or config
	end

	---
	-- @param string key
	-- @param mixed value
	-- @param[opt] string group
	function Module:set(key, value, group)
		key = type(key) == 'string' and key or ''
		group = group and groups[group] or nil
		local result, firstKey, lastKey = config
		for k in strgmatch(key, '[^%.]+') do
			if lastKey then
				result[lastKey] = type(result[lastKey]) == 'table' and result[lastKey] or { }
				result = result[lastKey]
			end
			lastKey, firstKey = k, firstKey or k
		end
		if firstKey and group then
			group[#group + 1] = firstKey
		end
		if lastKey then
			result[lastKey] = value
		end
	end

	---
	-- @param string filepath
	-- @param[opt] string group
	-- @param[opt=false] boolean reset
	function Module:load(filepath, group, reset)
		group = group and groups[group] or nil
		if reset then
			config = { }
		end
		local data = Parser:parseFile(filepath)
		if not data then return end
		if group then
			for i = 1, #group do
				config[group[i]] = copy(data[group[i]], config[group[i]])
			end
		else
			config = copy(data, config)
		end
	end

	---
	-- @param string filepath
	-- @param[opt] string group
	function Module:save(filepath, group)
		Parser:dumpToFile(filepath, self:all(group))
	end

return setmetatable(Module, {
	__index = config,
	__call = function (self, k, v, group) return v ~= nil and self:set(k, v, group) or self:get(k) end
})