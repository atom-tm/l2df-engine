--- Frames component
-- @classmod l2df.class.component.frames
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local log = core.import 'class.logger'
local helper = core.import 'helper'
local Component = core.import 'class.component'

local type = _G.type
local pairs = _G.pairs
local clone = helper.copyTable

local added_data = { }
local ignored = { 1, 2, id = 1, keyword = 1 }

local Frames = Component:extend({ unique = true })

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity obj
	-- @param table kwargs
	function Frames:added(obj, kwargs)
		if not obj then return false end
		kwargs = kwargs or { }

		local data = obj.data
		obj.data[self] = { added = { }, list = { }, map = { }, counter = 0 }

		obj.C.frames = self:wrap(obj)

		kwargs.frame = kwargs.frame or 1
		kwargs.frames = kwargs.frames or { }

		data.frame = { }
		data.wait = 0
		data.next = kwargs.frame

		for i = 1, #kwargs.frames do
			self:add(obj, kwargs.frames[i], i)
		end
		self:set(obj, kwargs.frame)
	end

	function Frames:removed(obj)
		self.super.removed(self, obj)
		obj.C.frames = nil
	end

    --- Add new frame with specified id
	-- @param table frame
	-- @param number id
	function Frames:add(obj, frame, id)
		local storage = self:data(obj)
		frame.id = frame.id or frame[1] or id
		frame.keyword = frame.keyword or frame[2]
		if not type(frame) == 'table' then
			return
		end
		if frame.keyword then
			storage.map[frame.keyword] = frame.id
		end
		storage.list[frame.id] = frame
	end

	function Frames:stats(obj)
		local storage = self:data(obj)
		local size = 0
		for x in pairs(storage.list) do
			size = size + 1
		end
		local frame = obj.data.frame
		return size, frame.wait, frame.id, frame.next, storage.counter
	end

	--- Change current frame
	-- @param number id
	-- @param number remain
	function Frames:set(obj, id, remain)
		local storage = self:data(obj)
		local nextFrame =
			storage.list[id] or
			(storage.map[id] and storage.list[storage.map[id]]) or
			storage.list[next(storage.list)]
		if not nextFrame then
			if obj.data.frame.id then
				log:warn('Frame not found: %s[%s]', obj.name, obj.key)
			end
			return
		end
		local data = obj.data
		data.frame = clone(nextFrame)
		data.next = nextFrame.next
		data.wait = nextFrame.wait or 0
		storage.counter = remain or 0
		if nextFrame.keyword then
			storage.map[nextFrame.keyword] = nextFrame.id
		end
	end

	--- Pre-update event
	-- @param number dt
	function Frames:preupdate(obj, dt)
		local data = obj.data
		local storage = self:data(obj)
		if storage.counter >= data.wait then
			storage.counter = storage.counter - data.wait
			self:set(obj, data.next, storage.counter)
		end
		if not data.frame.id then
			return
		end
		local adata = storage.added
		for i = 1, #adata do
			data[adata[i][1]] = adata[i][2]
			adata[i] = nil
		end
		for k, v in pairs(data.frame) do
			if not ignored[k] then
				adata[#adata + 1] = { k, data[k] }
				data[k] = v
			end
		end
		storage.counter = data.wait > 0 and storage.counter + dt * 1000 or 0
	end

return Frames
