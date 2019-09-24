local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EntityManager works only with l2df v1.0 and higher')

local Storage = core.import 'core.class.storage'
local State = core.import 'core.class.state'

local helper = core.import 'helper'

local list = { }
local Manager = { }

	function Manager:add(filepath)
		local req, key = helper.requireFile(filepath)
		list[key] = req
	end

	function Manager:load(folderpath)
		local r = helper.requireFolder(folderpath, true, '[0-9]+')
		for k, v in pairs(r) do
			list[k] = v
		end
	end

	function Manager:get(state)
		list[state] = list[state] or State:new()
		return list[state]
	end

return Manager