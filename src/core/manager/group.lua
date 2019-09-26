local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EntityManager works only with l2df v1.0 and higher')

local Storage = core.import 'core.class.storage'

local objects = {}
local groups = {}
local classes = {}

local Manager = { }

	--- Embed references to Manager methods in the entity instance that you create
	--  @tparam Entity entity
	function Manager:classInit(entity)
		if entity.___class then
			classes[entity.___class] = classes[entity.___class] or Storage:new()
			classes[entity.___class]:add(entity)
		end
		entity.addTags = self.addTags
		entity.removeTags = self.removeTags
		entity.hasTags = self.hasTags
		entity.getTags = self.getTags
	end


	--- Returns all objects that are instances of the class
	--  @tparam Class class
	--  @treturn table
	function Manager:getByClass(class)
		local result = { }
		if not classes[class] then return result end
		for k, v in classes[class]:enum(true) do
			result[#result + 1] = v
		end
		return result
	end


	--- Returns all objects that are heirs of the class
	--  @tparam Class class
	--  @treturn table
	function Manager:getByInstance(class)
		local result = { }
		local matches = { }
		for key in pairs(classes) do
			if key:isInstanceOf(class) then
				for k, v in classes[key]:enum(true) do
					if not matches[v] then
						matches[v] = true
						result[#result + 1] = v
					end
				end
			end
		end
		return result
	end


	--- Add tags to object
	--  @tparam object self
	--  @tparam mixed tags
	function Manager.addTags(self, tags)
		tags = type(tags) == 'table' and tags or { tags }
		local tag = nil
		for i = 1, #tags do
			tag = tags[i]
			groups[tag] = groups[tag] or Storage:new()
			groups[tag]:add(self)
			objects[self] = objects[self] or Storage:new()
			objects[self]:add(tag)
		end
	end


	--- Remove tags from object
	--  @tparam object self
	--  @tparam mixed tags
	function Manager.removeTags(self, tags)
		tags = type(tags) == 'table' and tags or { tags }
		for i = 1, #tags do
			groups[tags[i]]:remove(self)
			objects[self]:remove(tags[i])
		end
	end


	--- Gets a list of object tags
	--  @tparam mixed self
	--  @treturn table
	function Manager.getTags(self)
		local result = { }
		for k, v in objects[self]:enum(true) do
			result[#result + 1] = v
		end
		return result
	end


	--- Checks if an object has tags
	--  @tparam object self
	--  @tparam mixed tags
	function Manager.hasTags(self, tags)
		tags = type(tags) == 'table' and tags or { tags }
		for i = 1, #tags do
			if not groups[tags[i]]:has(self) then
				return false
			end
		end
		return true
	end


	--- Returns a list of objects that contain the specified tag
	--  @tparam mixed tag
	--  @treturn table
	function Manager:getByTag(tag)
		local result = { }
		for k, v in groups[tag]:enum(true) do
			result[#result + 1] = v
		end
		return result
	end


	--- Returns a list of objects that satisfy the filter
	--  @tparam mixed tags
	--  @tparam function filter
	--  @treturn table
	function Manager:getByFilter(tags, filter)
		tags = type(tags) == 'table' and tags or { tags }
		filter = type(filter) == 'function' and filter or function (e)
			return e:hasTags(tags)
		end

		local matches, result = { } , { } -- it looks like a face, I decided to save it

		for i = 1, #tags do
			for k, v in groups[tags[i]]:enum(true) do
				if not matches[v] and filter(v) then
					matches[v] = true
					result[#result + 1] = v
				end
			end
		end

		return result
	end

return Manager