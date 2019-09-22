local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "EntityManager works only with l2df v1.0 and higher")

local Class = core.import "core.class"
local Storage = core.import "core.class.storage"

local list = {
	temp = Storage:new(),
	global = Storage:new()
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

	function Manager:resoursesEnum( )
		for k, v in self.list.global:enum(true) do
			if self.list.temp:has(v) then
				print(k .. " - " .. tostring(v) .. " [temp]")
			else
				print(k .. " - " .. tostring(v))
			end
		end
	end

	function Manager:resoursesList()
		for k, v in self.list.global:pairs() do
			if self.list.temp:has(v) then
				print(k .. " - " .. tostring(v) .. " [temp]")
			else
				print(k .. " - " .. tostring(v))
			end
		end
		-- body
	end



return Manager