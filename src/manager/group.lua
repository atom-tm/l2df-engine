--- Grouping manager.
-- Can be used for classification, filtering or querying of the created @{l2df.class.entity|entities} / @{table|objects}.
-- @classmod l2df.manager.group
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'GroupManager works only with l2df v1.0 and higher')

local Storage = core.import 'class.storage'

local objects = { }
local groups = { }
local classes = { }

local Manager = { }

	--- Configure @{l2df.manager.group|GroupManager}.
	-- Currently does nothing.
	-- @param[opt] table kwargs  Keyword arguments. Not actually used.
	-- @return l2df.manager.group
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		return self
	end

	--- Embed references to @{l2df.manager.group|GroupManager's} methods in the entity instance that you create.
	-- Also adds created entity's instance to the list of known classes. Embedded methods are:
	-- @{Manager.addTags|addTags}, @{Manager.removeTags|removeTags}, @{Manager.hasTags|hasTags} and @{Manager.getTags|getTags}.
	-- @param l2df.class.entity entity  Entity's instance.
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

	--- Returns all objects that are instances of the class.
	-- @param l2df.class class  Class of the entity that was used to create it.
	-- @return {l2df.class.entity,...}  The list of entities.
	function Manager:getByClass(class)
		local result = { }
		if not classes[class] then return result end
		for k, v in classes[class]:enum(true) do
			result[#result + 1] = v
		end
		return result
	end

	--- Returns all objects that are heirs of the class.
	-- @param l2df.class class  Entity's class or its predecessor.
	-- @return {l2df.class.entity,...}  The list of entities.
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

	--- Add tags to the object.
	-- @param table|l2df.class.entity self  Object to attach tags.
	-- @param[opt] {mixed,...}|mixed tags  Tag or array of tags to add.
	-- Can be of any hashable type (in other words not `userdata`).
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

	--- Remove tags from the object.
	-- @param table|l2df.class.entity self  Object to remove tags from.
	-- @param[opt] {mixed,...}|mixed tags  Tag or array of tags to remove.
	function Manager.removeTags(self, tags)
		tags = type(tags) == 'table' and tags or { tags }
		for i = 1, #tags do
			groups[tags[i]]:remove(self)
			objects[self]:remove(tags[i])
		end
	end

	--- Gets a list of object's tags.
	-- @param table|l2df.class.entity self  Object to observe for tags.
	-- @return {mixed,...}  The list of found tags.
	function Manager.getTags(self)
		local result = { }
		for k, v in objects[self]:enum(true) do
			result[#result + 1] = v
		end
		return result
	end

	--- Checks if an object has tags.
	-- @param table self  Object to check.
	-- @param[opt] {mixed,...}|mixed tags  Tag or array of tags to check for existence.
	function Manager.hasTags(self, tags)
		tags = type(tags) == 'table' and tags or { tags }
		for i = 1, #tags do
			if not groups[tags[i]]:has(self) then
				return false
			end
		end
		return true
	end

	--- Returns a list of objects that contain the specified tag.
	-- @param mixed tag  Can be of any hashable type (in other words not `userdata`).
	-- @return {l2df.class.entity,...}  The list of entities.
	function Manager:getByTag(tag)
		local result = { }
		for k, v in groups[tag]:enum(true) do
			result[#result + 1] = v
		end
		return result
	end

	--- Returns a list of objects that satisfy the filter.
	-- @param[opt] {mixed,...}|mixed tags  Tag or array of tags to check for existence.
	-- @param[opt] function filter  Filter function accepts the only argumenty - @{l2df.class.entity|entity} instance.
	-- @return {l2df.class.entity,...}  The list of entities.
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

return setmetatable(Manager, { __call = Manager.init })