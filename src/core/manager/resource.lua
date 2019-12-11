--- Resource manager
-- @classmod l2df.core.manager.resource
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'ResourceManager works only with l2df v1.0 and higher')

local Class = core.import 'core.class'
local Storage = core.import 'core.class.storage'

local fs = love and love.filesystem

local list = {
	temp = Storage:new(),
	global = Storage:new()
}

--- List of extensions for the file download function
local extensions = {
	image = {
		['.png'] = true,
		['.bmp'] = true,
		['.gif'] = true,
	},
	sound = {
		['.ogg'] = true,
		['.wav'] = true,
		['.mp3'] = true,
	},
	video = {
		['.ogv'] = true,
	},
	font = {
		['.ttf'] = true,
		['.otf'] = true,
	},
}

local Manager = { }

	--- Saves the resource to the Manager
	--  @param mixed resource
	--  @param boolean temp
	--  @return number id
	--  @return mixed resource
	function Manager:add(resource, temp)
		if not resource then return false end
		if temp then list.temp:add(resource, true) end
		return list.global:add(resource, true)
	end

	--- Stores the resource in the Manager using a unique identifier
	--  @param mixed id
	--  @param mixed resource
	--  @param boolean temp
	--  @return mixed id
	--  @return mixed resource
	function Manager:addById(id, resource, temp)
		if not id then return self:add(resource, temp) end
		if temp then list.temp:add(resource, true) end
		return list.global:addById(resource, id, true)
	end

	--- Removes the specified resource from the Manager
	--  @param mixed resource
	--  @return boolean success
	function Manager:remove(resource)
		list.temp:remove(resource)
		return list.global:remove(resource)
	end

	--- Removes the specified resource from the Manager by Id
	--  @param mixed id
	--  @return boolean success
	function Manager:removeById(id)
		local res = list.global:getById(id)
		if not res then return true end
		list.temp:remove(res)
		return list.global:removeById(id)
	end

	--- Removes all resources marked as temporary from the Manager
	function Manager:clearTemp()
		for k, val in list.temp:enum(true) do
			list.global:remove(val)
		end
		list.temp = Storage:new()
	end

	--- Gets the resource Id from the Manager
	--  @param mixed resource
	--  @return mixed id
	function Manager:getId(resource)
		return list.global:has(resource)
	end

	--- Returns a resource from the Manager by Id
	--  @param mixed id
	--  @return mixed resource
	--  @return boolean is the resource marked temporary
	function Manager:get(id)
		local res = list.global:getById(id)
		return res, id, list.temp:has(res)
	end

	--- Checks the availability of the resource in the Manager by the Id
	--  @param mixed id
	--  @return boolean
	function Manager:has(id)
		return list.global:getById(id) and true or false
	end

	--- Adds a supported file type to the Manager by loading it from a path
	--  @param string filepath
	--  @param boolean reload
	--  @param mixed id
	--  @return mixed id
	--  @return mixed resource
	function Manager:load(filepath, reload, id)
		local id = id or filepath
		if not reload and self:get(id) then return self:get(id) end
		local resource = nil
		local extension = filepath:match('^.+(%..+)$')
		if extensions.image[extension] then
			resource = love.graphics.newImage(filepath)
		elseif extensions.video[extension] then
			resource = love.graphics.newVideo(filepath)
		elseif extensions.sound[extension] then
			resource = love.audio.newSource(filepath)
		elseif extensions.font[extension] then
			resource = love.graphics.newFont(filepath)
		else return end
		id, resource = self:addById(id, resource)
		return resource, id
	end

	local assync_loading = [[
		local listtoupload, ResourceManager = ...
		local progress = love.thread.getChannel("assychLoad")
		for i = 1, #listtoupload do
			local filepath = listtoupload.path
			ResourceManager:load(filepath)
			local percent = #listtoupload * 0.01 * i
			progress:push({ false, percent })
		end
		progress:push({ true, 100 })
	]]
	local assychLoad = love.thread.newThread(assync_loading)
	function Manager:assychLoad(list)
		local result = love.thread.getChannel("assychLoad"):pop()
		if result and result[1] then return true
		elseif result then return false
		else assychLoad:start(list) end
		return false
	end

return Manager