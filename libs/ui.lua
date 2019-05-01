local UI = object:extend()

function UI:init(x,y)
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

UI.Image = UI:extend()
UI.Text = UI:extend()
UI.Button = UI:extend()


function UI.Image:init(x,y,file)
	self:super(x, y)
	self.resource = file and image.Load(file) or nil
end

function UI.Text:init(x,y,content)
	self:super(x, y)
	self.content = content
end

function UI.Text:draw()
	if self.hidden then return end
	font.print(self.content, self.x, self.y)
end

	UI.Video = UI:extend()
	function UI.Video:init(x, y, file, stretch)
		self:super(x,y)
		self.video = videos.load(file)
		self.stretch = stretch or false
	end

	function UI.Video:draw()
		videos.draw(self.video,self.x,self.y,self.stretch)
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
		UI.init(self,x,y)
		self.resource = file and image.Load(file,{w = w or 1, h = h or 1, x = row or 1, y = col or 1}) or nil
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
			if self.frame == self.max_frames then
				if self.looped then self.frame = 1 end
			else
				self.frame = self.frame + 1
			end
		end
	end

	function UI.Animation:draw()
		if self.hidden then return end
		image.draw(self.resource,self.frame,self.x,self.y)
	end

return UI