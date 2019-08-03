local core = l2df or require((...):match("(.-)[^%.]+$") .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Images works only with l2df v1.0 and higher")
assert(type(love) == "table", "Images works only under love2d environment")

local fs = love.filesystem
local notNil = core.import("helper").notNil

local images = { list = { global = {}, temporary = {} }, load, draw }

--- Loads an image into an array
local function loadResourse(filepath, global, linear, mipmaps, wrap)
	local index = filepath

	local resourse = images.list.global[index] or images.list.temporary[index] or nil
	if resourse then return resourse end

	local storage = global and images.list.global or images.list.temporary
	storage[index] = love.graphics.newImage(filepath, {linear = linear, mipmaps = mipmaps})
	resourse = storage[index]
	if resourse then
		resourse:setWrap(wrap,wrap)
		return resourse
	end

	return nil
end

--- Adds a frame
local function addQuad(self, x, y, w, h, id)
	local quad = love.graphics.newQuad(x, y, w, h, self.info.width, self.info.height)
	id = id or #self.quads + 1
	self.quads[id] = quad
	self.info.frames = self.info.frames + 1
end

	--- Clearing an array of temporary resources to free up memory
	function images.clear()
		for key in pairs(images.list.temporary) do
			images.list.temporary[key] = nil
		end
		images.list.temporary = {}
	end

	--- Loads an image and returns the object of that image
	function images.load(filepath, cutting_info, privacy, properties)

		if not (filepath and fs.getRealDirectory(filepath)) then return end

		local image = { resourse, batch, quads = {}, info = {} }
		local w, h, x, y
		local x_offset, y_offset = 0, 0
		local linear, mipmaps, wrap, global = false, true, "clampzero", true
		local info = {width = 0, height = 0, frames = 1}

		if type(properties) == "table" then
			linear = notNil(properties.linear, linear)
			mipmaps = notNil(properties.mipmaps, mipmaps)
			wrap = notNil(properties.wrap, wrap)
			global = notNil(properties.global, global)
		else
			linear = notNil(properties, linear)
		end

		image.resourse = loadResourse(filepath, global, linear, mipmaps, wrap)
		if not image.resourse then return end

		cutting_info = type(cutting_info) == "table" and cutting_info or {}
		w = cutting_info.w or cutting_info[1] or info.width
		h = cutting_info.h or cutting_info[2] or info.height
		x = cutting_info.x or cutting_info[3] or 1
		y = cutting_info.y or cutting_info[4] or 1
		x_offset = cutting_info.x_offset or cutting_info[5] or 0
		y_offset = cutting_info.y_offset or cutting_info[6] or 0

		info.width = image.resourse:getWidth()
		info.height = image.resourse:getHeight()
		info.frames = x * y

		image.batch = info.frames > 1 and love.graphics.newSpriteBatch(image.resourse)
		image.info = info
		image.addQuad = addQuad
		image.draw = images.draw

		image:addQuad(0, 0, info.width, info.height, 0)

		for j = 0, y - 1 do
			for i = 0, x - 1 do
				image:addQuad(i * w + x_offset, j * h + y_offset, w, h)
			end
		end

		return image
	end


	function images.draw(self, x, y, frame, facing, arguments, color)

		sprite = self and self.resourse
		if not sprite then return end

		facing = facing and -1 or 1
		x = x or 0
		y = y or 0
		frame = self.quads[frame or 0]

		local sx, sy, ra, ox, oy, kx, ky = 1, 1, 0, 0, 0, 0, 0
		local r, g, b, a = 1, 1, 1, 1
		local ro, go, bo, ao = love.graphics.getColor()

		if type(arguments) == "table" then
			sx = arguments.sx or arguments[1] or sx
			sy = arguments.sy or arguments[2] or sy
			ra = arguments.ra or arguments[3] or ra
			ox = arguments.ox or arguments[4] or ox
			oy = arguments.oy or arguments[5] or oy
			kx = arguments.kx or arguments[6] or kx
			ky = arguments.ky or arguments[7] or ky
		else
			sx = arguments or sx
			sy = arguments or sy
		end

		color = type(color) == "table" and color or {}
		r = color.r or color[1] or ro
		g = color.g or color[2] or go
		b = color.b or color[3] or bo
		a = color.a or color[4] or ao

		love.graphics.setColor(r, g, b, a)
		love.graphics.draw(sprite, frame, x, y, ra, sx * facing, sy, ox, oy, kx, ky)
		love.graphics.setColor(ro, go, bo, ao)

	end

	--[[function images.draw(image, sprite, x, y, facing, size, r,g,b,a, other)
		if size == nil then size = 1 end
		if facing == 0 or facing == nil then facing = 1 end
		local width = 1
		local height = 1
		if type(size) == "number" then
			width = size
			height = size
		else
		    width = size.width
		    height = size.height
		end
		other = other or {
			r = 0,
			ox = 0, oy = 0,
			kx = 0, ky = 0,
		}
		local ro, go, bo, ao = love.graphics.getColor()
		love.graphics.setColor(r or ro, g or go, b or bo, a or ao)
		if sprite and sprite ~= 0 then
			love.graphics.draw(image.image,image.sprites[sprite],x,y,other.r,width * facing,height,other.ox,other.oy,other.kx,other.ky)
		else
			love.graphics.draw(image.image,x,y,other.r,width * facing,height,other.ox,other.oy,other.kx,other.ky)
		end
		love.graphics.setColor(ro, go, bo, ao)
	end]]

return images

