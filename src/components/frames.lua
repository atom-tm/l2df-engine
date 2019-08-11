local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "FramesComponent works only with l2df v1.0 and higher")

local Component = core.import "core.entities.component"

local random = math.random
local type = _G.type

local FramesComponent = Component:extend({
	frames = { },
	frames_list = { }, 
	facing = 1,
	wait = 0,
	next_frame = 0,
	head = {
		default_idle = "idle",
		default_air = "air_idle"
	}
})

	--- Set current frame
	-- @param key, string|number  Frame key
	-- @param i, number  frames_list subkey
	function FramesComponent:setFrame(key, i)
		if type(key) == "number" then
			if key == 0 and self.head and self.head.next_zero then
				if self.y > 0 then
					return self:setFrame(self.head.default_air)
				end
				return self:setFrame(self.head.default_idle)
			elseif key < 0 then
				self.facing = -self.facing
				key = -key
			end

			if self.frames[key] then
				self.frame = self.frames[key]
				self.wait = self.frame.wait
				self.next_frame = self.frame.next
				return true
			end

		elseif type(key) == "string" then
			if type(self.frames_list[key]) == "number" then
				return self:setFrame(self.frames_list[key])
			elseif type(self.frames_list[key]) == "table" then
				local len = #self.frames_list[key]
				i = i ~= nil and i > 0 and i <= len and i or random(1, len)
				return self:setFrame(self.frames_list[key][i])
			end
		end
		return false
	end

return FramesComponent