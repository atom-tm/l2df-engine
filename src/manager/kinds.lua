--- Kinds manager
-- @classmod l2df.manager.kinds
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'KindsManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local Kind = core.import 'class.kind'

local pairs = _G.pairs

local requireFile = helper.requireFile
local requireFolder = helper.requireFolder

local list = { }

local Manager = { }

	--- Adds the kind file to the list
	-- @param string filepath
	function Manager:add(filepath)
		local req, key = requireFile(filepath)
		list[key] = req
	end

	--- Loads kind files from the specified folder
	-- @param string folderpath
	function Manager:load(folderpath)
		local r = requireFolder(folderpath, true)
		for k, v in pairs(r) do
			if v.isInstanceOf and v.isInstanceOf(Kind) then
				list[k] = v
			end
		end
	end

	--- Gets a kind from the list by its number
	-- @param number kind
	-- @return l2df.class.kind
	function Manager:get(kind)
		return list[kind] or nil
	end

return Manager