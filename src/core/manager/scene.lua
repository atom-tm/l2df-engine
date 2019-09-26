local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EntityManager works only with l2df v1.0 and higher')


----█---█-███-████----
----█-█-█--█--████----
----█████--█--█-------
----─█-█--███-█-------


local Scene = core.import 'core.class.entity.scene'
local Storage = core.import 'core.class.storage'
local helper = core.import 'helper'

local list = Storage:new()
local histrory = { }

local Manager = { }

	function Manager:classInit(entity)
		if not entity:isInstanceOf(Entity) then return end
		entity:setActive(false)
	end


	function Manager:load(folderpath)
		local r = helper.requireFolder(folderpath, true)
		for k, v in pairs(r) do
			if v.isInstanceOf and v:isInstanceOf(Scene) then
				list:addById(v, k)
			end
		end
	end


	function Manager:add(filepath, id)
		if not filepath then return end
		if filepath.isInstanceOf and filepath:isInstanceOf(Scene) and id then
			list:addById(filepath, id)
			return
		end
		local req, key = helper.requireFile(filepath)
		if req.isInstanceOf and req:isInstanceOf(Scene) then
			list:addById(req, key)
		end
	end

	function Manager:remove(room)
		if not room then return end
		list:remove(room)
	end


	function Manager:removeById(id)
		list:removeById(id)
	end


	function Manager:set(id)
		for k, v in list:pairs(true) do
			v:setActive(false)
		end
		local set = list:getById(id)
		assert(set, "Room by current Id does not exist")
		histrory = { set }
		return set:setActive(true)
	end


	function Manager:push(id)
		local set = list:getById(id)
		assert(set, "Room by current Id does not exist")
		histrory[#histrory + 1] = set
		return set:setActive(true)
	end


	function Manager:pop()
		if #histrory < 1 then return false end
		histrory[#histrory]:setActive(false)
		histrory[#histrory] = nil
		return true
	end

return Manager