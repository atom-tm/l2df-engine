--- Frames component. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.frames
-- @author Abelidze
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
local ignored = { 1, 2, id = 1, keyword = 1, ___shallow = 1 }

local Frames = Component:extend({ unique = true })

	--- Table describing &lt;frame&gt; structure.
	-- @field number id  Frame's main identifier. Should be unique.
	-- @field[opt] string keyword  Frame's string identifier used for easy and transparent coding process. Should be unique.
	-- @field[opt] number|string next  ID / name of the frame to switch to automatically.
	-- @field[opt=0] number wait  Number of the milliseconds to wait for switching to the next frame.
	-- @field ... ...  There're may be any amount of the &lt;key:value&gt; pairs.
	-- All of them would be copied to the @{l2df.class.entity.data|entity's data} from the current frame
	-- with call to @{l2df.class.component.frames.preupdate|Frames:preupdate()}.
	-- @table .Frame

	--- Current frame's counter (in milliseconds). Used for switching frames automatically.
	-- To access use @{l2df.class.component.data|Frames:data()} function.
	-- @number Frames.data.counter

	--- Component was added to @{l2df.class.entity|Entity} event.
	-- Adds `"frames"` key to the @{l2df.class.entity.C|Entity.C} table.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt=1] number|string kwargs.frame  ID / name of the starting frame.
	-- @param[opt] {l2df.class.component.frames.Frame,...} kwargs.frames  Array of frames to be added with @{l2df.class.component.frames.add|Frames:add()} method.
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

	--- Component was removed from @{l2df.class.entity|Entity} event.
	-- Removes `"frames"` key from @{l2df.class.entity.C|Entity.C} table.
	-- @param l2df.class.entity obj  Entity's instance.
	function Frames:removed(obj)
		self.super.removed(self, obj)
		obj.C.frames = nil
	end

	--- Add new frame with specified id.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param l2df.class.component.frames.Frame frame  Frame's data table to add.
	-- @param number id  ID of the adding frame. Ignored when @{l2df.class.component.frames.Frame|Frame.id} has been already set.
	function Frames:add(obj, frame, id)
		if not type(frame) == 'table' then
			return
		end
		local storage = self:data(obj)
		frame.___shallow = true
		frame.id = frame.id or frame[1] or id
		frame.keyword = frame.keyword or frame[2]
		if frame.keyword and not storage.map[frame.keyword] then
			storage.map[frame.keyword] = frame.id
		end
		storage.list[frame.id] = frame
	end

	--- Get statistical information. Mostly used for debug purposes.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @return number  Total frames count.
	-- @return number  Current frame's wait time.
	-- @return number  Current frame's ID.
	-- @return number|string  Next frame's ID / name.
	-- @return Frames.data.counter  Current frame's counter.
	function Frames:stats(obj)
		local storage = self:data(obj)
		local size = 0
		for x in pairs(storage.list) do
			size = size + 1
		end
		local frame = obj.data.frame
		return size, frame.wait, frame.id, frame.next, storage.counter
	end

	--- Change current frame.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number id  ID of the frame to set
	-- @param[opt=0] number counter  Initial @{Frames.data.counter} value after set
	function Frames:set(obj, id, counter)
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
		storage.counter = counter or 0
		if nextFrame.keyword then
			storage.map[nextFrame.keyword] = nextFrame.id
		end
	end

	--- Frames pre-update event handler.
	-- @param l2df.class.entity obj  Entity's instance.
	-- @param number dt  Delta-time since last game tick.
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
