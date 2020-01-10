--- States manager
-- @classmod l2df.manager.states
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'StatesManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local State = core.import 'class.state'

local list = { }

local Manager = { }

	--- Adds the state file to the list
	--  @param string filepath
	function Manager:add(filepath)
		local req, key = helper.requireFile(filepath)
		list[key] = req
	end

	--- Loads state files from the specified folder
	--  @param string folderpath
	function Manager:load(folderpath)
		local r = helper.requireFolder(folderpath, true)
		for k, v in pairs(r) do
			if v.isInstanceOf and v.isInstanceOf(State) then
				list[k] = v
			end
		end
	end

	--- Gets a state from the list by its number
	--  @param number state
	--  @return State
	function Manager:get(state)
		return list[state] or nil
	end

return Manager