local images = {}
	
	images.list = {}
	function images.Load(file_path, cutting_info , filter)
		for i in pairs(images.list) do
			if images.list[i].path == file_path then
				return images.list[i]
			end
		end
		local image = {
			image = love.graphics.newImage(file_path),
			sprites = {},
			path = file_path
		}
		if cutting_info ~= nil then
			for i = 0, cutting_info.y - 1 do
				for j = 0, cutting_info.x - 1 do
					quad = love.graphics.newQuad(cutting_info.w*j, cutting_info.h*i ,cutting_info.w,cutting_info.h, image.image:getDimensions())
					table.insert(image.sprites, quad)
				end
			end
			image.w = cutting_info.w
		end
		if filter ~= nil then image.image:setFilter(filter, filter) end
		table.insert(images.list, image)
		return image
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
		if other == nil then
			other = {
				r = 0,
				ox = 0,
				oy = 0,
				kx = 0,
				ky = 0
			}
		end
		local ro,go,bo,ao = love.graphics.getColor()
		if r == nil then r = ro end
		if g == nil then g = go end
		if b == nil then b = bo end
		if a == nil then a = ao end
		love.graphics.setColor(r, g, b, a)
		if sprite == 0 or sprite == nil then
			love.graphics.draw(image.image,x,y,0,width * facing,height)
		else
			love.graphics.draw(image.image,image.sprites[sprite],x,y,other.r,width * facing,height,other.ox,other.oy,other.kx,other.ky)
		end
		love.graphics.setColor(ro, go, bo, ao)
	end

return images