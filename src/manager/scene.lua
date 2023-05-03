--- Scene manager.
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

	--- Configure @{l2df.manager.scene|SceneManager}.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt] string kwargs.load  Path to the directory containing scene presets to @{Manager:load|load}.
	-- @param[opt] number|string kwargs.set  Scene ID of the initial scene to @{Manager:set|set}.
	-- @return l2df.manager.scene
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		if kwargs.load then
			self:load(kwargs.load)
		end
		if kwargs.set then
			self:set(kwargs.set)
		end
		return self
	end

	--- Load preset scenes from a specified folder.
	-- @param string folderpath  Path to the directory containing scene presets.
	function Manager:load(folderpath)
		local r = helper.requireFolder(folderpath, true)
		for k, v in pairs(r) do
			if type(v) == 'table' and v.isInstanceOf and v:isInstanceOf(Scene) then
				list[k] = v
				self.root:attach(v)
			end
		end
	end

	--- Load preset scene from file or scene object preserving the id.
	-- @param string|l2df.class.entity.scene scene  Path to the scene file or @{l2df.class.entity.scene|Scene} object.
	-- @param[opt] number|string id  Scene ID.
	-- If `scene` is a string, the default value is a name of the scene's file.
	-- @return boolean  `true` if scene was successfully added. `false` otherwise.
	function Manager:add(scene, id)
		assert(scene, 'You must specify the path to the file or pass the scene object')
		if scene.isInstanceOf and scene:isInstanceOf(Scene) and id then
			list[id] = scene
			self.root:attach(scene)
			return true
		end
		local v, key = helper.requireFile(scene)
		key = id or key
		if v.isInstanceOf and v:isInstanceOf(Scene) then
			list[key] = v
			self.root:attach(v)
			return true
		end
		return false
	end

	--- Deleting a scene from the Manager by Id
	-- @param number|string id  Scene ID.
	-- @return boolean
	function Manager:remove(id)
		if not id then return false end
		self.root:detach(list[id])
		list[id] = nil
		return true
	end

	--- Check whether a scene with the specified id is @{Manager:set|setted} / @{Manager:push|pushed} to stack.
	-- @param number|string id  Scene ID.
	-- @return boolean  `true` if the scene is in stack. `false` otherwise.
	function Manager:inStack(id)
		local scene = assert(id and list[id], 'Room with provided id does not exist')
		for i = #history, 1, -1 do
			if history[i] == scene then
				return true
			end
		end
		return false
	end

	--- Returns the topmost scene in @{Manager:push|stack}.
	-- @return l2df.class.entity.scene
	function Manager:current()
		return history[#history]
	end

	--- Setting the current scene.
	-- @param number|string id  Scene ID.
	-- @param ... ...  Passes all arguments to `enter` / `leave` / `disable` callbacks of the @{l2df.class.entity.scene|scene}.
	-- @return boolean
	function Manager:set(id, ...)
		for i = #history, 1, -1 do
			history[i]:setActive(false)
			local _ = history[i].leave and history[i]:leave(...)
			history[i] = nil
		end
		return self:push(id, ...)
	end

	--- Adding scene to current list.
	-- @param number|string id  Scene ID.
	-- @param ... ...  Passes all arguments to `enter` / `disable` callbacks of the @{l2df.class.entity.scene|scene}.
	-- @return boolean
	function Manager:push(id, ...)
		local scene = history[#history]
		local _ = scene and scene.disable and scene:disable(...)
		scene = assert(id and list[id], 'Room with provided id does not exist')
		history[#history + 1] = scene
		return scene:setActive(true) and scene.enter and scene:enter(...) or true
	end

	--- Removing last scene from current list.
	-- @param ... ...  Passes all arguments to `enable` / `leave` callbacks of the @{l2df.class.entity.scene|scene}.
	-- @return boolean  `true` if there were one or more scenes in stack. `false` otherwise.
	function Manager:pop(...)
		if #history == 0 then return false end
		local scene = history[#history]
		local _ = scene:setActive(false) and scene.leave and scene:leave(...)
		history[#history] = nil
		scene = history[#history]
		return scene and scene:setActive(true) and scene.enable and scene:enable(...) or true
	end

return setmetatable(Manager, { __call = Manager.init })