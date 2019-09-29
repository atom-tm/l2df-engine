local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EntityManager works only with l2df v1.0 and higher')

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
	--  @tparam mixed resource
	--  @tparam boolean temp
	--  @treturn number id
	--  @tretutn mixed resource
	function Manager:add(resource, temp)
		if not resource then return false end
		if temp then list.temp:add(resource, true) end
		return list.global:add(resource, true)
	end

	--- Stores the resource in the Manager using a unique identifier
	--  @tparam mixed id
	--  @tparam mixed resource
	--  @tparam boolean temp
	--  @treturn mixed id
	--  @tretutn mixed resource
	function Manager:addById(id, resource, temp)
		if not id then return self:add(resource, temp) end
		if temp then list.temp:add(resource, true) end
		return list.global:addById(resource, id, true)
	end

	--- Removes the specified resource from the Manager
	--  @tparam mixed resource
	--  @treturn boolean success
	function Manager:remove(resource)
		list.temp:remove(resource)
		return list.global:remove(resource)
	end

	--- Removes the specified resource from the Manager by Id
	--  @tparam mixed id
	--  @treturn boolean success
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
	--  @tparam mixed resource
	--  @treturn mixed id
	function Manager:getId(resource)
		return list.global:has(resource)
	end

	--- Returns a resource from the Manager by Id
	--  @tparam mixed id
	--  @trerurn mixed resource
	--  @treturn boolean is the resource marked temporary
	function Manager:get(id)
		local res = list.global:getById(id)
		return res, list.temp:has(res)
	end

	--- Checks the availability of the resource in the Manager by the Id
	--  @tparam mixed id
	--  @treturn boolean
	function Manager:has(id)
		return list.global:getById(id) and true or false
	end

	--- Adds a supported file type to the Manager by loading it from a path
	--  @tparam string filepath
	--  @tparam boolean reload
	--  @tparam mixed id
	--  @treturn mixed id
	--  @treturn mixed resource
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
		return self:addById(id, resource)
	end

return Manager