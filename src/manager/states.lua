--- States manager
-- @classmod l2df.manager.states
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'StatesManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local type = _G.type
local pairs = _G.pairs

local list = { }

local Manager = { }

	--- Configure @{l2df.manager.states}
	-- @param table kwargs
	-- @return l2df.manager.states
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		return self
	end

	--- Adds the state file to the list
	-- @param string filepath
	function Manager:add(filepath)
		local req, key = helper.requireFile(filepath)
		if type(req) == 'function' then
			list[key] = req
		end
	end

	--- Loads state files from the specified folder
	-- @param string folderpath
	function Manager:load(folderpath)
		local r = helper.requireFolder(folderpath, true)
		for k, v in pairs(r) do
			if type(v) == 'function' then
				list[k] = v
			end
		end
	end

	--- Run specified state with arguments
	-- @param mixed state
	function Manager:run(state, ...)
		return list[state] and list[state](...)
	end

	--- Gets a state from the list by its key
	-- @param mixed state
	-- @return l2df.class.state
	function Manager:get(state)
		return list[state] or nil
	end

return setmetatable(Manager, { __call = Manager.init })