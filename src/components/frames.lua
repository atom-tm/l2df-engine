local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "FramesComponent works only with l2df v1.0 and higher")

local Component = core.import "core.entities.component"
local Media = core.import "media"

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
		default_air = "air_idle",
		sprites = { }
	},
	frame_timer = 0
})

	--- Init component, collect all pics
	function FramesComponent:init(entity)
		self.pics = { }
		if entity.head and entity.head.sprites then
			for i = 1, #entity.head.sprites do
				local sprite = entity.head.sprites[i]
				local info = {
					w = sprite.w,
					h = sprite.h,
					x = sprite.row,
					y = sprite.col,
					x_offset = sprite.x_offset,
					y_offset = sprite.y_offset
				}
				local img = Media.Image(sprite.file, info)
				local size = #self.pics
				for j = 1, img.info.frames do
					self.pics[size + j] = { img, j }
				end
			end
		end
		self:super(entity)
	end

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

	function FramesComponent:update(dt)
		if self.frame then
			self.frame_timer = self.frame_timer + dt * 1000
			local no_wait = not self.wait or self.wait == 0
			if no_wait or self.frame_timer > self.wait then
				self.frame_timer = self.frame_timer - (no_wait and self.frame_timer or self.wait)
				self:setFrame(self.next_frame)
			end
		end
	end

	function FramesComponent:draw()
		if not self.frame then return end
		local pic = self.pics[self.frame.pic]
		pic[1]:draw(self.x, self.y, pic[2])
	end

return FramesComponent