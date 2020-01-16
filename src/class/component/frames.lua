--- Frames component
-- @classmod l2df.class.component.frames
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'
local Frame = core.import 'class.entity.frame'

local Frames = Component:extend({ unique = true })

	---
	function Frames:init()
		self.entity = nil
	end

	---
	-- @param Entity entity
	-- @param number starting
	-- @param table frames
	function Frames:added(entity, starting, frames)
		if not entity then return false end
		self.entity = entity
		starting = starting or 1
		frames = frames or { }

		self.frame = nil
		self.wait = 0
		self.next = starting
		self.counter = 0

		self.list = { }
		self.map = { }
		for i = 1, #frames do
			self:add(frames[i], i)
		end
	end

	---
	-- @param l2df.class.entity.frame frame
	-- @param number id
	function Frames:add(frame, id)
		frame.id = frame.id or id
		if not (frame.isInstanceOf and frame:isInstanceOf(Frame) and frame.id) then
			return
		end

		if frame.keyword then
			self.map[frame.keyword] = frame
		end
		self.list[frame.id] = frame
	end

	---
	-- @param number id
	-- @param number remain
	function Frames:set(id, remain)
		local nextFrame = self.list[id] or self.map[id] or self.list[next(self.list)]
		if not nextFrame then return end

		self.frame = nextFrame
		self.next = nextFrame.next
		self.wait = nextFrame.wait
		self.map[nextFrame.keyword or ''] = nextFrame
		self.counter = remain or 0
	end

	---
	-- @param number dt
	function Frames:preUpdate(dt)
		if not self.entity.active then return end

		if self.counter >= self.wait then
			self.counter = self.counter - self.wait
			self:set(self.next, self.counter)
		end

		if not (self.frame and self.frame.vars) then return end
		for k, v in pairs(self.frame.vars) do
			self.entity.vars[k] = v
		end
		self.counter = self.wait > 0 and self.counter + dt * 1000 or 0
	end

return Frames