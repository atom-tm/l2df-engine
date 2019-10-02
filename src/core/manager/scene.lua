local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'SceneManager works only with l2df v1.0 and higher')

local Scene = core.import 'core.class.entity.scene'
local Storage = core.import 'core.class.storage'

local list = { }
local histrory = { }

local Manager = { root = Scene:new() }

	--- Initialization Scene class
	--  @tparam Entity entity
	function Manager:classInit(entity)
		entity:setActive(false)
	end

	--- Load presset scenes from a specified folder
	--  @tparam string folderpath
	function Manager:load(folderpath)
		local r = helper.requireFolder(folderpath, true)
		for k, v in pairs(r) do
			if v.isInstanceOf and v:isInstanceOf(Scene) then
				list[k] = v
				self.root:attach(v)
			end
		end
	end

	--- Load presset scene from file or scene object preserving the id
	--  @tparam string|Scene filepath
	--  @tparam mixed id
	--  @treturn boolean
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
	--  @tparam mixed id
	--  @treturn boolean
	function Manager:remove(id)
		if not id then return false end
		self.root:detach(list[id])
		list[id] = nil
		return true
	end

	--- Setting the current scene
	--  @tparam mixed id
	--  @treturn boolean
	function Manager:set(id)
		for i = 1, #histrory do
			histrory[i]:setActive(false)
		end
		histrory = { }
		return self:push(id)
	end

	--- Adding scene to current list
	--  @tparam mixed id
	--  @treturn boolean
	function Manager:push(id)
		local set = list[id]
		assert(set, 'Room by current Id does not exist')
		histrory[#histrory + 1] = set
		return set:setActive(true)
	end

	--- Removing last scene from current list
	--  @treturn boolean
	function Manager:pop()
		if not (#histrory > 1) then return false end
		histrory[#histrory]:setActive(false)
		histrory[#histrory] = nil
		return true
	end

return Manager