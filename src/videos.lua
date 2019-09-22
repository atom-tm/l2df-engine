local videos = { }

	videos.list = { }

	function videos.load(file_path)
		for i in pairs(videos.list) do
			if videos.list[i].path == file_path then
				return videos.list[i]
			end
		end
		local video = {
			resource = love.graphics.newVideo(file_path),
			path = file_path,
		}
		video.width, video.height = video.resource:getDimensions()
		videos.list[#videos.list + 1] = video
		return video
	end

	function videos.draw(video, x, y, stretch, facing, size, r,g,b,a, other)
		stretch = stretch or false
		facing = facing and facing ~= 0 or 1
		if facing == 0 or facing == nil then facing = 1 end
		local width = size and size.width or size or 1
		local height = size and size.height or size or 1
		if stretch then width = width * (settings.gameWidth / video.width) end
		if stretch then height = height * (settings.gameHeight / video.height) end
		other = other or { r = 0, ox = 0, oy = 0, kx = 0, ky = 0 }
		local ro,go,bo,ao = love.graphics.getColor()
		r = r or ro
		g = g or go
		b = b or bo 
		a = a or ao 
		love.graphics.setColor(r, g, b, a)
		love.graphics.draw(video.resource,x,y,other.r,width * facing,height,other.ox,other.oy,other.kx,other.ky)
		love.graphics.setColor(ro, go, bo, ao)
	end

return videos