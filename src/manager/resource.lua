--- Resource manager
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

local fs = love and love.filesystem
local min = math.min

local asyncList = { }
local asyncChannel = love.thread.getChannel('asyncChannel')
local asyncReturn = love.thread.getChannel('asyncReturn')
local asyncLoader = love.thread.newThread([[
	require 'love.image'
	local extensions = ...
	local asyncChannel = love.thread.getChannel('asyncChannel')
	local asyncReturn = love.thread.getChannel('asyncReturn')
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
				resource = love.image.newImageData(file)
			else print("error extensions") end
			if resource then
				asyncReturn:push({ id = id, resource = resource, extension = extension, temp = temp })
			end
		else continuation = false end
		collectgarbage()
	end
]])

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

local callbacks = { }

local Manager = { }
	--- Saves the resource to the Manager
	--  @param mixed resource
	--  @param boolean temp
	--  @return number id
	--  @return mixed resource
	function Manager:add(resource, temp)
		if resourse == nil then return false end
		local id = nil
		if temp then id = list.temp:add(resource, true)
		else id = list.global:add(resource, true) end
		return id
	end

	--- Stores the resource in the Manager using a unique identifier
	--  @param mixed id
	--  @param mixed resource
	--  @param boolean temp
	--  @return mixed id
	--  @return mixed resource
	function Manager:addById(id, resource, temp)
		if not id then return self:add(resource, temp) end
		if resource == nil then return false end
		if temp then list.temp:addById(resource, id, true)
		else list.global:addById(resource, id, true) end
		return id
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
		return list.global:getById(id) or list.temp:getById(id) or nil
	end

	--- Adds a supported file type to the Manager by loading it from a path
	--  @param string filepath
	--  @param boolean reload
	--  @param mixed id
	--  @return mixed id
	--  @return mixed resource
	function Manager:load(filepath, reload, id, temp, ...)
		local id = id or filepath
		if not reload and self:get(id) then return id end
		if not fs.getInfo(filepath) then return false end
		local resource = nil
		local extension = filepath:match('^.+(%..+)$')
		if extensions.image[extension] then
			resource = love.graphics.newImage(filepath, ...)
		elseif extensions.video[extension] then
			resource = love.graphics.newVideo(filepath, ...)
		elseif extensions.sound[extension] then
			resource = love.audio.newSource(filepath, ...)
		elseif extensions.font[extension] then
			resource = love.graphics.newFont(filepath, ...)
		else return false end
		id = self:addById(id, resource, temp)
		return id
	end

	---
	function Manager:update()
		if #asyncList > 0 then
			for i = 1, #asyncList do
				asyncChannel:push(asyncList[i])
			end
			asyncList = { }
			if not asyncLoader:isRunning() then asyncLoader:start(extensions) end
		end
		if asyncReturn:getCount() > 0 then
			local returned = asyncReturn:pop()
			if extensions.image[returned.extension] then
				returned.resource = love.graphics.newImage(returned.resource)
			end
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

	--- Добавляет новый файл в список на загрузку, либо возвращает уже загруженный
	function Manager:loadAsync(filepath, callback, reload, id, temp)
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
		if not fs.getInfo(filepath) then return false end
		local extension = filepath:match('^.+(%..+)$')
		if callback then callbacks[id] = { callback } end
		asyncList[#asyncList + 1] = { id, filepath, extension, temp }
		id = self:addById(id, Plug:new(), temp)
		return id
	end

	--- Загрузка списка файлов с проверкой завершенности
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

return Manager
















--[[


local asyncLoader = function (self)

	if not current_file then

		local object = asyncList:first()
		if not object then return end

		local id = object[1]
		local file = object[2]
		local extension = object[3]

		if file:open("r") then
			current_file = {
				id = id,
				file = file,
				extension = extension,
				size = file:getSize(),
				data = "",
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
			print("end")
		end
	end
end


]]