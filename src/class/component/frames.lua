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

		local vars = entity.vars

		starting = starting or 1
		frames = frames or { }

		vars.frame = nil
		vars.wait = 0
		vars.next = starting
		vars.counter = 0

		self.list = { }
		self.map = { }
		for i = 1, #frames do
			self:add(frames[i], i)
		end
	end

	---
	function Frames:removed(entity)
		local vars = entity.vars

		vars.frame = nil
		vars.wait = nil
		vars.counter = nil
		vars.next = nil

		self.entity = nil
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
		if not self.entity then return end

		local nextFrame = self.list[id] or self.map[id] or self.list[next(self.list)]
		if not nextFrame then return end

		local vars = self.entity.vars
		vars.frame = nextFrame
		vars.next = nextFrame.next
		vars.wait = nextFrame.wait
		vars.counter = remain or 0
		if nextFrame.keyword then
			self.map[nextFrame.keyword] = nextFrame
			-- TODO: this can break sync, fix it in future with list's ids
		end
	end

	---
	-- @param number dt
	function Frames:preUpdate(dt)
		if not self.entity.active then return end

		local vars = self.entity.vars
		if vars.counter >= vars.wait then
			vars.counter = vars.counter - vars.wait
			self:set(vars.next, vars.counter)
		end

		if not (vars.frame and vars.frame.vars) then return end
		for k, v in pairs(vars.frame.vars) do
			vars[k] = v
		end
		vars.counter = vars.wait > 0 and vars.counter + dt * 1000 or 0
	end

return Frames