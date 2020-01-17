--- Scene manager
-- @classmod l2df.manager.scene
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require((...):match('(.-)manager.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'SceneManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local Scene = core.import 'class.entity.scene'
local Storage = core.import 'class.storage'

local list = { }
local history = { }

local Manager = { root = Scene { active = true } }

	--- Load presset scenes from a specified folder
	--  @param string folderpath
	function Manager:load(folderpath)
		local r = helper.requireFolder(folderpath, true)
		for k, v in pairs(r) do
			if type(v) == 'table' and v.isInstanceOf and v:isInstanceOf(Scene) then
				list[k] = v
				self.root:attach(v)
			end
		end
	end

	--- Load presset scene from file or scene object preserving the id
	--  @param string|Scene filepath
	--  @param mixed id
	--  @return boolean
	function Manager:add(filepath, id)
		assert(filepath, 'You must specify the path to the file or pass the scene object')
		if filepath.isInstanceOf and filepath:isInstanceOf(Scene) and id then
			list[id] = filepath
			self.root:attach(filepath)
			return true
		end
		local req, key = helper.requireFile(filepath)
		key = id or key
		if req.isInstanceOf and req:isInstanceOf(Scene) then
			list[key] = req
			self.root:attach(req)
			return true
		end
		return false
	end

	--- Deleting a scene from the Manager by Id
	--  @param mixed id
	--  @return boolean
	function Manager:remove(id)
		if not id then return false end
		self.root:detach(list[id])
		list[id] = nil
		return true
	end

	--- Setting the current scene
	--  @param mixed id
	--  @return boolean
	function Manager:set(id, ...)
		for i = #history, 1, -1 do
			history[i]:setActive(false)
			local _ = history[i].leave and history[i]:leave(...)
			history[i] = nil
		end
		return self:push(id, ...)
	end

	--- Adding scene to current list
	--  @param mixed id
	--  @return boolean
	function Manager:push(id, ...)
		local scene = assert(list[id], 'Room with provided id does not exist')
		history[#history + 1] = scene
		local _ = scene.enter and scene:enter(...)
		return scene:setActive(true)
	end

	--- Removing last scene from current list
	--  @return boolean
	function Manager:pop(...)
		if not (#history > 0) then return false end
		local scene = history[#history]
		scene:setActive(false)
		history[#history] = nil
		return scene.leave and scene:leave(...) or true
	end

return Manager