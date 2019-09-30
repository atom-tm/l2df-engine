local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EntityManager works only with l2df v1.0 and higher')

local Scene = core.import 'core.class.entity.scene'
local Storage = core.import 'core.class.storage'

local list = { }
local histrory = { }

local Manager = { root = Scene:new() }







	--- ВРЕМЕННАЯ ФУНКЦИЯ Т.К. КОЕ КТО ОПЯТЬ ЧУДИТ
	function requireFolder(folderpath, keys, pattern)

		local fs = love and love.filesystem
		local strformat = string.format
		local strjoin = table.concat
		local strfind = string.find
		local strgsub = string.gsub
		local strrep = string.rep
		local floor = math.floor
		local sqrt = math.sqrt
		local pow = math.pow
		local parser = core.import 'parsers.lffs'


		local result = { }
		if fs and folderpath and fs.getInfo(folderpath, 'directory') then
			folderpath = strfind(folderpath, '/$') and folderpath or folderpath .. '/'

			local modulepath = core.modulepath(folderpath)
			local files = fs.getDirectoryItems(folderpath)


			local id, file
			for i = 1, #files do
				if (not pattern or strfind(files[i], pattern)) and strfind(files[i], '.lua$') then
					file = strgsub(files[i], '.lua$', '')
					id = keys and file or #result + 1
					result[id] = require(modulepath .. file)
				elseif (not pattern or strfind(files[i], pattern)) and strfind(files[i], '.dat$') then

					file = files[i]
					id = keys and file or #result + 1
					id = strgsub(id, '.dat$', '')
					local s, n = fs.read(folderpath .. file)
					result[id] = parser:parse(s)
				end
			end
		end
		return result
	end

















	--- Initialization Scene class
	--  @tparam Entity entity
	function Manager:classInit(entity)
		entity:setActive(false)
	end

	--- Load presset scenes from a specified folder
	--  @tparam string folderpath
	function Manager:load(folderpath)
		local r = requireFolder(folderpath, true)
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