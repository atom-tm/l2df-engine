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

local cfdata = { }
local groups = { }

local Config = { }

	--- Combine and return full config for the specified group / all groups.
	-- @param[opt] string group  Specified group.
	-- @return table
	function Config:all(group)
		local g = group and groups[group] or nil
		if not g then
			return cfdata
		end
		local data = { }
		for i = 1, #g do
			data[g[i]] = cfdata[g[i]]
		end
		return data
	end

	--- Create new config's group and assign key-paths to it.
	-- @param string group  Specified group.
	-- @param {string,...} ...  Key-paths in format 'path.to.value'.
	function Config:group(group, ...)
		local data = groups[group] or { }
		for i = 1, select('#', ...) do
			data[#data + 1] = select(i, ...)
		end
		groups[group] = data
	end

	--- Get config value by key-path.
	-- @param string key  Key-path in format 'path.to.value'.
	-- @return mixed
	function Config:get(key)
		key = type(key) == 'string' and key or ''
		local result
		for k in strgmatch(key, '[^%.]+') do
			result = result and result[k] or cfdata[k]
		end
		return result or cfdata
	end

	--- Update <key:value> pair in config and set assign it to specified group if needed.
	-- @param string key  Key-path in format 'path.to.value'.
	-- @param mixed value  Value.
	-- @param[opt] string group  Specified group.
	function Config:set(key, value, group)
		key = type(key) == 'string' and key or ''
		group = group and groups[group] or nil
		local result, firstKey, lastKey = cfdata
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

	--- Load config to specified group / all groups from JSON file.
	-- @param string filepath  Path to JSON config.
	-- @param[opt] string group  Specified group.
	-- @param[opt=false] boolean reset  Reset already loaded config.
	function Config:load(filepath, group, reset)
		group = group and groups[group] or nil
		if reset then
			cfdata = { }
		end
		local data = Parser:parseFile(filepath)
		if not data then return end
		if group then
			for i = 1, #group do
				cfdata[group[i]] = copy(data[group[i]], cfdata[group[i]])
			end
		else
			cfdata = copy(data, cfdata)
		end
	end

	--- Save config for specified group / all groups to JSON file.
	-- @param string filepath  Path to JSON config.
	-- @param[opt] string group  Specified group.
	function Config:save(filepath, group)
		Parser:dumpToFile(filepath, self:all(group))
	end

return setmetatable(Config, {
	__index = cfdata,
	__newindex = Config.set,
	__call = function (self, k, v, group) return v ~= nil and self:set(k, v, group) or self:get(k) end
})