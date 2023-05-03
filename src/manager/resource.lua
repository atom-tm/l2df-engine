--- Resource manager.
-- @classmod l2df.manager.resource
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'ResourceManager works only with l2df v1.0 and higher')

local Class = core.import 'class'

local log = core.import 'class.logger'
local Storage = core.import 'class.storage'
local Plug = core.import 'class.plug'
local helper = core.import 'helper'
local notNil = helper.notNil

local type = _G.type
local unpack = table.unpack or _G.unpack
local fs = core.api.io
local min = math.min
local strmatch = string.match
local loveNewImage = core.api.data.image
local loveNewVideo = core.api.data.video
local loveNewSource = core.api.data.audio
local loveNewFont = core.api.data.font

local asyncList = { }
local asyncChannel = core.api.async.channel('asyncChannel')
local asyncReturn = core.api.async.channel('asyncReturn')
local asyncLoader = core.api.async.create([[
	pcall(require, 'love.image')
	pcall(require, 'love.video')
	local extensions, lib = ...
	local api = require(lib)
	local strformat = string.format
	local asyncChannel = api.async.channel('asyncChannel')
	local asyncReturn = api.async.channel('asyncReturn')
	local continuation = true
	while continuation do
		local task = asyncChannel:pop()
		if task then
			local id = task[1]
			local file = task[2]
			local extension = task[3]
			local temp = task[4]
			local resource = nil
			if extensions.image[extension] then
				resource = api.data.pixels(file)
			elseif extensions.video[extension] then
				resource = api.data.stream(file)
			elseif extensions.sound[extension] then
				resource = id
			else
				resource = api.data.file(file)
			end
			if resource then
				asyncReturn:push({ id = id, resource = resource, extension = extension, temp = temp })
			end
		else continuation = false end
		collectgarbage()
		api.async.yield()
	end
]])

local list = {
	temp = Storage:new(),
	global = Storage:new()
}

--- List of supported extensions by resource type
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

local arguments = { }
local callbacks = { }

local Manager = { }

	--- Configure @{l2df.manager.resource|ResourceManager}.
	-- @param[opt] table kwargs  Keyword arguments. Not actually used.
	-- @return l2df.manager.resource
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		return self
	end

	--- Saves the resource to the @{l2df.manager.resource|ResourceManager}.
	-- @param mixed resource  Resource handler.
	-- @param[opt=false] boolean temp  Set to true if the specified resource should be marked as @{Manager:clearTemp|temporary}.
	-- @return number|boolean id
	-- @return mixed resource
	function Manager:add(resource, temp)
		if resourse == nil then return false end
		local id = nil
		if temp then id = list.temp:add(resource, true)
		else id = list.global:add(resource, true) end
		return id, resource
	end

	--- Stores the resource in the @{l2df.manager.resource|ResourceManager} using an unique identifier.
	-- @param number|string id  Unique identifier for accessing resource later.
	-- @param mixed resource  Resource handler.
	-- @param[opt=false] boolean temp  Set to true if the specified resource should be marked as @{Manager:clearTemp|temporary}.
	-- @return number|string|boolean id
	-- @return mixed resource
	function Manager:addById(id, resource, temp)
		if not id then return self:add(resource, temp) end
		if resource == nil then return false end
		list[temp and 'temp' or 'global']:addById(resource, id, true)
		return id, resource
	end

	--- Removes the specified resource from the @{l2df.manager.resource|ResourceManager}.
	-- @param mixed resource  Resource handler.
	-- @return boolean success
	function Manager:remove(resource)
		list.temp:remove(resource)
		return list.global:remove(resource)
	end

	--- Removes the specified resource from the @{l2df.manager.resource|ResourceManager} by its ID.
	-- @param number|string id  Resource's unique identifier.
	-- @return boolean success
	function Manager:removeById(id)
		local res = list.global:getById(id)
		if not res then return true end
		list.temp:remove(res)
		return list.global:removeById(id)
	end

	--- Removes all resources marked as temporary from the @{l2df.manager.resource|ResourceManager}.
	function Manager:clearTemp()
		for k, val in list.temp:enum(true) do
			list.global:remove(val)
		end
		list.temp = Storage:new()
	end

	--- Gets the resource Id from the @{l2df.manager.resource|ResourceManager}.
	-- @param mixed resource  Resource handler.
	-- @return number|string id
	function Manager:getId(resource)
		return list.global:has(resource)
	end

	--- Returns a resource from the @{l2df.manager.resource|ResourceManager} by its ID.
	-- @param number|string id  Resource's unique identifier.
	-- @return mixed resource  Resource handler.
	-- @return boolean is the resource marked temporary
	function Manager:get(id)
		return id and (list.global:getById(id) or list.temp:getById(id)) or nil
	end

	--- Adds a supported file type to the @{l2df.manager.resource|ResourceManager} by loading it from a path.
	-- @param string filepath  Path to the resource file.
	-- @param[opt=false] boolean reload  Set to true if you want to reload previously loaded resource.
	-- @param[opt] number|string id  Resource's unique identifier for accessing it later.
	-- Defaults to `filepath` if not setted.
	-- @param[opt=false] boolean temp  Set to true if the specified resource should be marked as @{Manager:clearTemp|temporary}.
	-- @return mixed id
	-- @return mixed resource
	function Manager:load(filepath, reload, id, temp, ...)
		local id = id or filepath
		if not reload and self:get(id) then return id end
		local path, extension = strmatch(filepath, '^(.+)(%..+)$')
		if filepath and not (fs.getInfo(filepath) or path == '__default__') then
			print('failed', filepath)
			return false
		end
		local resource = nil
		if extensions.image[extension] then
			resource = loveNewImage(filepath, ...)
		elseif extensions.video[extension] then
			resource = loveNewVideo(filepath, ...)
		elseif extensions.sound[extension] then
			resource = loveNewSource(filepath, 'static', ...)
		elseif extensions.font[extension] then
			resource = path == '__default__' and loveNewFont(...) or loveNewFont(filepath, ...)
		else return false end
		id = self:addById(id, resource, temp)
		return id, resource
	end

	--- Update event handler.
	-- Checks async loaders and triggers callbacks if they are finished.
	function Manager:update()
		local taskCount = #asyncList
		for i = 1, taskCount do
			asyncChannel:push(asyncList[i])
			asyncList[i] = nil
		end
		if not core.api.async.isrunning(asyncLoader) and taskCount > 0 then
			local lib = 'l2df.api'
			for k, v in pairs(package.loaded) do
				if v == core.api then
					lib = k
					break
				end
			end
			core.api.async.start(asyncLoader, extensions, lib)
		end
		if asyncReturn:getCount() > 0 then
			local returned = asyncReturn:pop()
			if extensions.image[returned.extension] then
				returned.resource = loveNewImage(returned.resource, unpack(arguments[returned.id]))
			elseif extensions.video[returned.extension] then
				returned.resource = loveNewVideo(returned.resource, unpack(arguments[returned.id]))
			elseif extensions.font[returned.extension] then
				returned.resource = loveNewFont(returned.resource, unpack(arguments[returned.id]))
			elseif extensions.sound[returned.extension] then
				returned.resource = loveNewSource(returned.resource, 'stream')
			end
			arguments[returned.id] = nil
			self:addById(returned.id, returned.resource, returned.temp)
			local c = callbacks[returned.id]
			if c then
				for i = 1, #c do
					c[i](returned.id, returned.resource)
				end
				callbacks[returned.id] = nil
			end
			log:debug('Async loaded: %s', returned.id)
		else asyncReturn:clear() end
	end

	--- Add new file to queue for async loading or return already loaded resource's ID.
	-- @param string filepath  Path to the resource file.
	-- @param[opt] function callback  Callback function which would be triggered on resource loading finished.
	-- Arguments for that function are: `(id, number|string)` and `(resource, mixed)`.
	-- @param[opt=false] boolean reload  Set to true if you want to reload previously loaded resource.
	-- @param[opt] number|string id  Resource's unique identifier for accessing it later.
	-- Defaults to `filepath` if not setted.
	-- @param[opt=false] boolean temp  Set to true if the specified resource should be marked as @{Manager:clearTemp|temporary}.
	-- @return number
	function Manager:loadAsync(filepath, callback, reload, id, temp, ...)
		id = id or filepath
		local res = self:get(id)
		if not reload and res then
			if callback and type(res) == 'table' and res.isInstanceOf and res:isInstanceOf(Plug) then
				callbacks[id] = callbacks[id] or { }
				callbacks[id][#callbacks[id] + 1] = callback
			elseif callback then
			    callback(id, res)
			end
			return id
		end
		local path, extension = strmatch(filepath, '^(.+)(%..+)$')
		if path == '__default__' and callback then
			callback(self:load(filepath, reload, id, temp, ...))
			return id
		end
		if not fs.getInfo(filepath) then return false end
		if callback then callbacks[id] = { callback } end
		arguments[id] = { ... }
		asyncList[#asyncList + 1] = { id, filepath, extension, temp }
		return self:addById(id, Plug:new(), temp)
	end

	--- Async loading of multiple resources.
	-- @param table files
	-- @return boolean
	-- @return number
	function Manager:loadListAsync(files)
		local result = #files
		local temp
		for i = 1, #files do
			temp = self:get(files[i])
			if temp == nil then self:loadAsync(files[i])
			elseif not (type(temp) == 'table' and temp.isInstanceOf and temp:isInstanceOf(Plug)) then
				result = result - 1
			end
		end
		return result == 0, result
	end

return setmetatable(Manager, { __call = Manager.init })

--[[
local asyncLoader = function (self)

	if not current_file then

		local object = asyncList:first()
		if not object then return end

		local id = object[1]
		local file = object[2]
		local extension = object[3]

		if file:open('r') then
			current_file = {
				id = id,
				file = file,
				extension = extension,
				size = file:getSize(),
				data = '',
				object = object
			}
		else asyncList:remove(object) end
	else
		local quantity = min(1024000,current_file.size)
		local data, size = current_file.file:read(quantity)
		current_file.size = current_file.size - size
		current_file.data = current_file.data .. data
		if current_file.size <= 0 then


			current_file.file:close()
			asyncList:remove(current_file.object)


			local filedata = love.filesystem.newFileData(current_file.data,current_file.id)
			local imagedata = love.image.newImageData(filedata)
			local resource = love.graphics.newImage(imagedata)


			self:addById(current_file.id, resource, true)
			current_file = nil
			print('end')
		end
	end
end
]]