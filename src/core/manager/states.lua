local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EntityManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local list = { }

local Manager = { }

	--- Adds the state file to the list
	--  @tparam string filepath
	function Manager:add(filepath)
		local req, key = helper.requireFile(filepath)
		list[key] = req
	end

	--- Loads state files from the specified folder
	--  @tparam string folderpath
	function Manager:load(folderpath)
		local r = helper.requireFolder(folderpath, true, '[0-9]+')
		for k, v in pairs(r) do
			list[k] = v
		end
	end

	--- Gets a state from the list by its number
	--  @tparam number state
	--  @treturn State
	function Manager:get(state)
		return list[state] or nil
	end

return Manager