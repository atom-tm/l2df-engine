local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "EntityManager works only with l2df v1.0 and higher")

local Class = core.import "core.class"
local Storage = core.import "core.class.storage"
local fs = love and love.filesystem

local list = {
	temp = Storage:new(),
	global = Storage:new()
}

local extensions = {
	image = {
		[".png"] = true,
		[".bmp"] = true,
		[".gif"] = true,
	},
	sound = {
		[".ogg"] = true,
		[".wav"] = true,
		[".mp3"] = true,

	},
	video = {
		[".ogv"] = true,
	},
}

local Manager = { list = list }

	function Manager:add(resourse, temp)
		if not resourse then return false end
		if temp then self.list.temp:add(resourse, true) end
		return self.list.global:add(resourse, true)
	end

	function Manager:addById(id, resourse, temp)
		if not resourse then return false end
		if temp then self.list.temp:add(resourse, true) end
		return self.list.global:addById(resourse, id, true)
	end

	function Manager:remove(resourse)
		if not resourse then return false end
		self.list.temp:remove(resourse)
		return self.list.global:remove(resourse)
	end

	function Manager:removeById(id)
		local res = self.list.global:getById(id)
		if not res then return true end
		self.list.temp:remove(res)
		return self.list.global:removeById(id)
	end

	function Manager:clearTemp()
		for k, val in self.list.temp:enum(true) do
			self.list.global:remove(val)
		end
		self.list.temp = Storage:new()
	end

	function Manager:getId(resourse)
		return self.list.global:has(resourse)
	end

	function Manager:get(id)
		local res = self.list.global:getById(id)
		return res, self.list.temp:has(res)
	end

	function Manager:has(id)
		return self.list.global:getById(id) and true or false
	end

	function Manager:load(filepath, reload)
		if not reload and self:get(filepath) then return self:get(filepath) end
		local extension = filepath:match("^.+(%..+)$")
		local id, resourse
		if extensions.image[extension] then
			id, resourse = self:addById(filepath, love.graphics.newImage(filepath))
		elseif extensions.video[extension] then
			id, resourse = self:addById(filepath, love.graphics.newVideo(filepath))
		elseif extensions.sound[extension] then
			id, resourse = self:addById(filepath, love.audio.newSource(filepath))
		else
			print("Unsupported format")
		end
		return resourse
	end



return Manager