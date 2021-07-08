--- States manager.
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

	--- State is a function for processing entities' logic depending on their frame / current "state".
	-- <br>It assepts these arguments:<br>
	-- * `obj` (@{l2df.class.entity}) - entity instance for which this state was attached;<br>
	-- * `data` (@{l2df.class.entity.data}) - entity's data;<br>
	-- * `params` (@{l2df.class.component.states.State|State} or @{l2df.class.component.states.ConstantState|ConstantState})
	-- - table containing different additional data.
	-- @field function .State

	--- Configure @{l2df.manager.states|StatesManager}.
	-- Currently does nothing.
	-- @param[opt] table kwargs  Keyword arguments. Not actually used.
	-- @return l2df.manager.states
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		return self
	end

	--- Adds the state file to the list.
	-- @param string filepath  Path to the state script-file.
	function Manager:add(filepath)
		local req, key = helper.requireFile(filepath)
		if type(req) == 'function' then
			list[key] = req
			if tonumber(key) then
				list[tonumber(key)] = req
			end
		end
	end

	--- Loads state files from the specified folder.
	-- @param string folderpath  Path to the directory containing state script-files.
	function Manager:load(folderpath)
		local r = helper.requireFolder(folderpath, true)
		for k, v in pairs(r) do
			if type(v) == 'function' then
				list[k] = v
				if tonumber(k) then
					list[tonumber(k)] = v
				end
			end
		end
	end

	--- Run specified state with arguments.
	-- @param number|string state  State name.
	-- @param ... ...  Arguments passed to the @{l2df.manager.states.State|state-function}.
	-- @return mixed|nil  Result of the @{l2df.manager.states.State|state-function} execution.
	function Manager:run(state, ...)
		return list[state] and list[state](...)
	end

	--- Gets a state from the list by its key.
	-- @param number|string state  State name.
	-- @return l2df.manager.states.State|nil
	function Manager:get(state)
		return list[state] or nil
	end

return setmetatable(Manager, { __call = Manager.init })