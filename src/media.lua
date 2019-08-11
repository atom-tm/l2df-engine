local core = l2df or require((...):match("(.-)[^%.]+$") .. "core")
assert(type(core) == "table" and core.version >= 1.0, "UI works only with l2df v1.0 and higher")

local helper = core.import("helper")
local object = core.import("core.object")

local fs = love and love.filesystem
local notNil = helper.notNil

local extensions = {
	image = {
		[".png"] = true,
		[".bmp"] = true,
		[".gif"] = true,
	},
	sound = {
		[".ogg"] = true,
		[".wav"] = true,
		[".mp3"] = true,

	},
	video = {
		[".ogv"] = true,
	},
}

local media_list = { permanent = {}, temporary = {} }


local function getResourse(index)
	return media_list.permanent[index] or media_list.temporary[index] or nil
end


local function addResourse(filepath, arguments, temporary)

	local index = filepath and fs.getRealDirectory(filepath)..filepath

	local resource = getResourse(index)
	if resource then return resource end

	if not fs.getInfo(filepath) then return end

	local extension = filepath:match("^.+(%..+)$")
	local location = temporary and media_list.temporary or media_list.permanent
	arguments = type(arguments) == table and arguments or { }

	if extensions.image[extension] then
		location[index] = love.graphics.newImage(filepath, {linear = arguments.linear, mipmaps = arguments.mipmaps})
		resource = location[index]
		if arguments.wrap then resource:setWrap(arguments.wrap, arguments.wrap) end
	elseif extensions.video[extension] then
		location[index] = love.graphics.newVideo(filepath, {audio = arguments.audio})
		if arguments.filter then resource:setFilter(arguments.filter, arguments.filter) end
		resource = location[index]
	elseif extensions.sound[extension] then
		if arguments.static then
			location[index] = love.audio.newSource(filepath, "static")
		else
			location[index] = love.audio.newSource(filepath, "stream")
		end
	end

	return resource

end


local function removeResourse(index)
	media_list.permanent[index] = nil
	media_list.temporary[index] = nil
end


local function clearTemp()
	for key in pairs(media_list.temporary) do
		media_list.temporary[key] = nil
	end
	media_list.temporary = {}
end

local function play(self)
	self.resource:play()
end
local function pause(self)
	self.resource:pause()
end
local function rewind(self)
	self.resource:rewind()
end

local Media = { }

	Media.clear = clearTemp
	Media.Image = object:extend()
	Media.Video = object:extend()
	Media.Sound = object:extend()
	Media.Music = object:extend()

	function Media.draw(object, ...)
		object:draw(...)
	end

	function Media.Image:init(filepath, cutting_info, privacy, properties)

		self.resource = addResourse(filepath, properties, privacy)
		self.info = {
			width = self.resource and self.resource:getWidth() or 0,
			height = self.resource and self.resource:getHeight() or 0,
			frames = 0
		}
		self.quads = {}

		cutting_info = type(cutting_info) == "table" and cutting_info or {}
		w = cutting_info.w or cutting_info[1] or self.info.width
		h = cutting_info.h or cutting_info[2] or self.info.height
		x = cutting_info.x or cutting_info[3] or 1
		y = cutting_info.y or cutting_info[4] or 1
		x_offset = cutting_info.x_offset or cutting_info[5] or 0
		y_offset = cutting_info.y_offset or cutting_info[6] or 0

		self:addQuad(0, 0, self.info.width, self.info.height, 0)

		for j = 0, y - 1 do
			for i = 0, x - 1 do
				self:addQuad(i * w + x_offset, j * h + y_offset, w, h)
			end
		end
	end


	function Media.Image:addQuad(x, y, w, h, id)
		local quad = love.graphics.newQuad(x, y, w, h, self.info.width, self.info.height)
		id = id or #self.quads + 1
		self.quads[id] = quad
		self.info.frames = self.info.frames + 1
	end


	function Media.Image:draw(x, y, frame, facing, arguments, color)
		sprite = self and self.resource
		if not sprite then return end

		facing = facing and -1 or 1
		x = x or 0
		y = y or 0
		frame = self.quads[frame or 0]

		local sx, sy, ra, ox, oy, kx, ky
		local r, g, b, a
		local ro, go, bo, ao = love.graphics.getColor()

		if type(arguments) == "table" then
			sx = arguments.sx or arguments[1]
			sy = arguments.sy or arguments[2]
			ra = arguments.ra or arguments[3]
			ox = arguments.ox or arguments[4]
			oy = arguments.oy or arguments[5]
			kx = arguments.kx or arguments[6]
			ky = arguments.ky or arguments[7]
		else
			sx = arguments or sx
			sy = sx
		end

		color = type(color) == "table" and color or {}
		r = color.r or color[1] or ro
		g = color.g or color[2] or go
		b = color.b or color[3] or bo
		a = color.a or color[4] or ao

		love.graphics.setColor(r, g, b, a)
		love.graphics.draw(sprite, frame, x, y, ra, sx and sx * facing, sy, ox, oy, kx, ky)
		love.graphics.setColor(ro, go, bo, ao)
	end


	function Media.Video:init(filepath, privacy, properties)
		self.resource = addResourse(filepath, properties, privacy)
		self.info = {
			width = self.resource and self.resource:getWidth() or 0,
			height = self.resource and self.resource:getHeight() or 0,
		}
		self.play = play
		self.pause = pause
		self.rewind = rewind
	end


	function Media.Video:draw(x, y, facing, arguments, color)
		video = self and self.resource
		if not video then return end

		facing = facing and -1 or 1
		x = x or 0
		y = y or 0

		local sx, sy, ra, ox, oy, kx, ky
		local r, g, b, a
		local ro, go, bo, ao = love.graphics.getColor()

		if type(arguments) == "table" then
			sx = arguments.sx or arguments[1]
			sy = arguments.sy or arguments[2]
			ra = arguments.ra or arguments[3]
			ox = arguments.ox or arguments[4]
			oy = arguments.oy or arguments[5]
			kx = arguments.kx or arguments[6]
			ky = arguments.ky or arguments[7]
		else
			sx = arguments or sx
			sy = sx
		end

		color = type(color) == "table" and color or {}
		r = color.r or color[1] or ro
		g = color.g or color[2] or go
		b = color.b or color[3] or bo
		a = color.a or color[4] or ao

		love.graphics.setColor(r, g, b, a)
		love.graphics.draw(video, x, y, ra, sx and sx * facing, sy, ox, oy, kx, ky)
		love.graphics.setColor(ro, go, bo, ao)
	end

	function Media.Video:switch()
		if self.resource:isPlaying() then
			self.resource:pause()
		else
			self.resource:play()
		end
	end


	function Media.Sound:init(filepath, privacy, properties)
		properties.static = true
		self.resource = addResourse(filepath, properties, privacy)
		self.play = play
		self.pause = pause
		self.rewind = rewind
	end

	function Media.Music:init(filepath, privacy, properties)
		properties.static = false
		self.resource = addResourse(filepath, properties, privacy)
		self.play = play
		self.pause = pause
		self.rewind = rewind
	end


return Media