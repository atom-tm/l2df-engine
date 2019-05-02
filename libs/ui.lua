	local UI = object:extend()

	function UI:init(x, y)
		self.x = x or 0
		self.y = y or 0
		self.hidden = false
	end

	function UI:update()
		-- plug
	end

	function UI:draw()
		-- plug
	end

	function UI:hide()
		self.hidden = true
	end

	function UI:show()
		self.hidden = false
	end

	function UI:edit(input)
		for key,val in pairs(input) do
			self[key] = val
		end
	end

	function UI:edit(input)
		for key,val in pairs(input) do
			self[key] = val
		end
	end

	UI.Button = UI:extend()
	function UI.Button:init(x, y, content, bg, action)
		self:super(x, y)
		self.content_n = type(content) == "string" and content or type(content) == "table" and content and content[1] or ""
		self.content_h = type(content) == "table" and content and content[2] or self.content_n or ""
		self.content_p = type(content) == "table" and content and content[3] or self.content_h or ""
		self.background_n = type(bg) == "string" and image.Load(bg) or type(bg) == "table" and bg and image.Load(bg[1]) or nil
		self.background_h = type(bg) == "table" and bg and bg[2] and image.Load(bg[2]) or self.background_n or ""
		self.background_p = type(bg) == "table" and bg and bg[3] and image.Load(bg[3]) or self.background_h or ""
		self.action = type(action) == "function" and action or function () end
		self.hover = false
		self.pressed = false
	end

	function UI.Button:draw(offsetX, offsetY)
		if self.hidden then return end
		offsetX = offsetX or 0
		offsetY = offsetY or 0
		--image.draw(self.resource, self.x + offsetX, self.y + offsetY)
		if self.pressed then
			if self.background_p then
				image.draw(self.background_p, self.x + offsetX, self.y + offsetY)
			end
			font.print(self.content_p, self.x + offsetX, self.y + offsetY)
		elseif self.hover then
			if self.background_h then
				image.draw(self.background_h, self.x + offsetX, self.y + offsetY)
			end
			font.print(self.content_h, self.x + offsetX, self.y + offsetY)
		else
			if self.background_n then
				image.draw(self.background_n, self.x + offsetX, self.y + offsetY)
			end
			font.print(self.content_n, self.x + offsetX, self.y + offsetY)
		end
	end


	UI.Text = UI:extend()
	function UI.Text:init(x, y, content)
		self:super(x, y)
		self.content = content
	end

	function UI.Text:draw(offsetX, offsetY)
		if self.hidden then return end
		offsetX = offsetX or 0
		offsetY = offsetY or 0
		font.print(self.content, self.x + offsetX, self.y + offsetY)
	end


	UI.Image = UI:extend()
	function UI.Image:init(x, y, file)
		self:super(x, y)
		self.resource = file and image.Load(file) or nil
	end

	function UI.Image:draw(offsetX, offsetY)
		if self.hidden then return end
		offsetX = offsetX or 0
		offsetY = offsetY or 0
		image.draw(self.resource, self.x + offsetX, self.y + offsetY)
	end


	UI.Video = UI:extend()
	function UI.Video:init(x, y, file, stretch)
		self:super(x,y)
		self.video = videos.load(file)
		self.stretch = stretch or false
	end

	function UI.Video:draw(offsetX, offsetY)
		offsetX = offsetX or 0
		offsetY = offsetY or 0
		videos.draw(self.video, self.x + offsetX, self.y + offsetY, self.stretch)
	end

	function UI.Video:play()
		self.video.resource:play()
	end

	function UI.Video:stop()
		self.video.resource:pause()
		self.video.resource:rewind()
	end

	function UI.Video:pause()
		self.video.resource:pause()
	end

	function UI.Video:hide()
		self.video.resource:pause()
		self.hidden = true
	end

	function UI.Video:show()
		self.video.resource:play()
		self.hidden = false
	end


	UI.Animation = UI:extend()
	function UI.Animation:init(x, y, file, w, h, row, col, frames, wait, looped)
		self:super(x, y)
		self.resource = file and image.Load(file, {w = w or 1, h = h or 1, x = row or 1, y = col or 1}) or nil
		self.frame = 1
		self.max_frames = frames
		self.wait = 0
		self.max_wait = wait or 1
		self.looped = looped or false
	end

	function UI.Animation:update()
		if self.wait < self.max_wait then
			self.wait = self.wait + 1
		else
			self.wait = 0
			if self.frame < self.max_frames then
				self.frame = self.frame + 1
			elseif self.looped then
				self.frame = 1
			end
		end
	end

	function UI.Animation:draw(offsetX, offsetY)
		if self.hidden then return end
		offsetX = offsetX or 0
		offsetY = offsetY or 0
		image.draw(self.resource,self.frame, self.x + offsetX, self.y + offsetY)
	end


	UI.List = UI:extend()
	function UI.List:init(x, y, content)
		assert(type(content) == "table", "Parameter 'content' must be a table.")
		self:super(x,y)
		self.content = content
		self.item = 1
		self.max_items = #content
 	end

 	function UI.List:draw(offsetX, offsetY)
		offsetX = offsetX or 0
		offsetY = offsetY or 0
 		for i = 1, self.max_items do
 			self.content[i]:draw(self.x + offsetX, self.y + offsetY)
 		end
 	end

 	function UI.List:update()
 		for i = 1, self.max_items do
 			self.content[i]:update()
 		end
 	end

return UI