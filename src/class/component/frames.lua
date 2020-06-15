--- Frames component
-- @classmod l2df.class.component.frames
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'
local Frame = core.import 'class.entity.frame'

local Frames = Component:extend({ unique = true })

	--- Init
	function Frames:init()
		self.entity = nil
	end

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity entity
	-- @param number starting
	-- @param table frames
	function Frames:added(entity, starting, frames, kwargs)
		if not entity then return false end
		kwargs = kwargs or { }
		self.entity = entity

		local vars = entity.vars

		entity.vars[self] = {
			list = { },
			map = { }
		}

		starting = starting or 1
		frames = frames or { }

		vars.frame = nil
		vars.wait = 0
		vars.next = starting
		vars.counter = 0

		for i = 1, #frames do
			self:add(frames[i], i)
		end

		if kwargs.frame then
		print(kwargs.frame)
			self:set(kwargs.frame)
		end
	end

    --- Component removed from l2df.class.entity
    -- @param l2df.class.entity entity
	function Frames:removed(entity)
		local vars = entity.vars

		vars.frame = nil
		vars.wait = nil
		vars.counter = nil
		vars.next = nil

		self.entity = nil
	end

    --- Add new frame with specified id
	-- @param l2df.class.entity.frame frame
	-- @param number id
	function Frames:add(frame, id)
		local storage = self.entity.vars[self]

		frame.id = frame.id or frame[1] or id
		if not (type(frame) == "table") then
			return
		end

		if frame.keyword then
			storage.map[frame.keyword] = frame
		end
		storage.list[frame.id] = frame
	end

	--- Change current frame
	-- @param number id
	-- @param number remain
	function Frames:set(id, remain)
		if not self.entity then return end

		local storage = self.entity.vars[self]

		local nextFrame = storage.list[id] or storage.map[id] or storage.list[next(storage.list)]
		if not nextFrame then return end

		local vars = self.entity.vars
		vars.frame = nextFrame
		vars.next = nextFrame.next
		vars.wait = nextFrame.wait or 0
		vars.counter = remain or 0
		if nextFrame.keyword then
			self.map[nextFrame.keyword] = nextFrame
			-- TODO: this can break sync, fix it in future with list's ids
		end
	end

	--- Pre-update event
	-- @param number dt
	function Frames:preUpdate(dt)
		if not self.entity.active then return end

		local vars = self.entity.vars
		if vars.counter >= vars.wait then
			vars.counter = vars.counter - vars.wait
			self:set(vars.next, vars.counter)
		end

		if not (type(vars.frame) == "table") then return end
		for k, v in pairs(vars.frame) do
			vars[k] = v
		end
		vars.counter = vars.wait > 0 and vars.counter + dt * 1000 or 0
	end

return Frames
