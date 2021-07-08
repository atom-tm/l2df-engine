--- Kinds manager.
-- @classmod l2df.manager.kinds
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'KindsManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local type = _G.type
local pairs = _G.pairs

local requireFile = helper.requireFile
local requireFolder = helper.requireFolder

local list = { }

local Manager = { }

	--- Kind is a function for handling collision events.
	-- <br>It assepts these arguments:<br>
	-- * `e1` (@{l2df.class.entity}) - the first entity for the triggered collision;<br>
	-- * `e2` (@{l2df.class.entity}) - the second entity for the triggered collision;<br>
	-- * `c1` (@{l2df.manager.physix.Collider}) - collider of the first entity;<br>
	-- * `c2` (@{l2df.manager.physix.Collider}) - collider of the second entity.
	-- @field function .Kind

	--- Configure @{l2df.manager.kinds|KindsManager}.
	-- Currently does nothing.
	-- @param[opt] table kwargs  Keyword arguments. Not actually used yet.
	-- @return l2df.manager.kinds
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		return self
	end

	--- Loads and adds the kind file to the local collection.
	-- @param string filepath  Path to the `".lua"` file containing @{l2df.manager.kinds.Kind|kind-function}.
	-- Name of the file will be used as kind's ID.
	function Manager:add(filepath)
		local req, key = requireFile(filepath)
		if type(req) == 'function' then
			list[key] = req
			if tonumber(key) then
				list[tonumber(key)] = req
			end
		end
	end

	--- Loads kind files from the specified directory.
	-- @param string directory  Directory to scan for `".lua"` files containing @{l2df.manager.kinds.Kind|kind-function}.
	-- For each loaded script name of the file will be used as kind's ID.
	function Manager:load(directory)
		local r = requireFolder(directory, true)
		for k, v in pairs(r) do
			if type(v) == 'function' then
				list[k] = v
				if tonumber(k) then
					list[tonumber(k)] = v
				end
			end
		end
	end

	--- Runs specified kind with arguments.
	-- @param number|string kind  ID / name of the kind
	-- @param ... ...  Arguments to be passed to @{l2df.manager.kinds.Kind|kind-function}.
	-- @return mixed|nil  Result of the @{l2df.manager.kinds.Kind|kind-function} execution.
	function Manager:run(kind, ...)
		return list[kind] and list[kind](...)
	end

	--- Gets a kind from the list by its key.
	-- @param number|string kind  ID / name of the kind
	-- @return l2df.manager.kinds.Kind|nil
	function Manager:get(kind)
		return list[kind] or nil
	end

return setmetatable(Manager, { __call = Manager.init })