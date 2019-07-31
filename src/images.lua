local core = l2df or require((...):match("(.-)[^%.]+$") .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Images works only with l2df v1.0 and higher")
assert(type(love) == "table", "Images works only under love2d environment")

local images = { list = { } }

	function images.Load(filepath, cutting_info , filter)
		for i in pairs(images.list) do
			if images.list[i].path == filepath then
				return images.list[i]
			end
		end
		local image = {
			image = love.graphics.newImage(filepath, {linear = true, mipmaps = true} ),
			sprites = {},
			path = filepath
		}
		image.image:setWrap("clampzero", "clampzero")
		if type(cutting_info) == "table" then
			cutting_info.x = cutting_info.x or 1
			cutting_info.y = cutting_info.y or 1
			cutting_info.mx = cutting_info.mx or 0
			cutting_info.my = cutting_info.my or 0
			for i = 0, cutting_info.y - 1 do
				for j = 0, cutting_info.x - 1 do
					quad = love.graphics.newQuad(cutting_info.w*j + cutting_info.mx, cutting_info.h*i + cutting_info.my ,cutting_info.w,cutting_info.h, image.image:getDimensions())
					table.insert(image.sprites, quad)
				end
			end
			image.w = cutting_info.w
			image.h = cutting_info.h
		else
			image.w, image.h = image.image:getDimensions()
		end
		if filter then
			image.image:setFilter(filter, filter)
		end
		table.insert(images.list, image)
		image.setQuad = images.setQuad
		return image
	end

	function images:setQuad(id, x, y, w, h)
		if id ~= nil and self.sprites[id] ~= nil then
			self.sprites[id]:setViewport(x,y,w,h)
			return id
		else
			local quad = love.graphics.newQuad(x,y,w,h, self.image:getDimensions())
			if id == nil then
				self.sprites[#self.sprites + 1] = quad
				return #self.sprites + 1
			else
				self.sprites[id] = quad
				return id
			end
		end
	end

	function images.draw(image, sprite, x, y, facing, size, r,g,b,a, other)
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
	end

return images