local core = l2df or require((...):match("(.-)[^%.]+$") .. "core")
assert(type(core) == "table" and core.version >= 1.0, "UI works only with l2df v1.0 and higher")

local i18n = core.import "i18n"
local videos = core.import "videos"
local fonts = core.import "fonts"
local images = core.import "images"
local settings = core.import "settings"
local Entity = core.import "core.entities.entity"

local fopen = io.open
local fs = love and love.filesystem

local UI = Entity:extend()

	function UI.resource(file)
		local path = settings.global.ui_path .. file
		if fs and fs.getInfo(path) then
			return path
		else
			local f = fopen(path, "r")
			if f then
				f:close()
				return path
			end
		end
		-- TODO: stuff below is a hardcoded resource == bad, needs refactor
		return settings.global.ui_path .. "dummy.png"
	end

	function UI:init(x, y, childs)
		self.x = x or 0
		self.y = y or 0
		self.hidden = false
		self.active = true
		self.childs = childs or { }
		assert(type(self.childs) == "table", "Parameter 'childs' must be a table.")
		for i = 1, #self.childs do
			local child = childs[i]
			assert(child and child:isInstanceOf(UI), "Only UI elements can be a part of UI.")
			child.x = child.x + self.x
			child.y = child.y + self.y
		end
	end

	function UI:on(event, callback)
		assert(type(event) == "string", "Event name must be string")
		assert(type(callback) == "function", "Callback must be a function")

		if type(self[event]) == "function" then
			local old = self[event]
			self[event] = function (...)
				old(...)
				callback(...)
			end
		end
		return self
	end

	function UI:hide()
		self.hidden = true
		return self
	end

	function UI:show()
		self.hidden = false
		return self
	end

	function UI:toggle()
		self.hidden = not self.hidden
		return self
	end

	function UI:edit(callback)
		local x, y = self.x, self.y

		if type(callback) == "function" then
			callback(self)
		elseif type(callback) == "table" then
			for k, v in pairs(callback) do
				self[k] = v
			end
		end

		if x ~= self.x or y ~= self.y then
			for i = 1, #self.childs do
				local child = self.childs[i]
				child.x = child.x - x + self.x
				child.y = child.y - y + self.y
			end
		end
		return self
	end


	UI.Image = UI:extend()
	function UI.Image:init(file, x, y, cutting, sprite, filter)
		self:super(x, y)
		self.resource = file and images.Load(file, cutting, filter)
		self.sprite = sprite or 0
	end

	function UI.Image:draw()
		images.draw(self.resource, self.sprite, self.x, self.y)
	end


	UI.Video = UI:extend()
	function UI.Video:init(file, x, y, stretch)
		self:super(x, y)
		self.video = videos.load(file)
		self.stretch = stretch or false
		self.size = { width = 1, height = 1 }
	end

	function UI.Video:resize(w, h)
		if self.stretch then
			self.size.width = core.settings.gameWidth / self.video.width
			self.size.height = core.settings.gameHeight / self.video.height
		end
	end

	function UI.Video:draw()
		videos.draw(self.video, self.x, self.y, self.size)
	end

	function UI.Video:play()
		self.video.resource:play()
		return self
	end

	function UI.Video:stop()
		self.video.resource:pause()
		self.video.resource:rewind()
		return self
	end

	function UI.Video:pause()
		self.video.resource:pause()
		return self
	end

	function UI.Video:hide()
		self.video.resource:pause()
		self.hidden = true
		return self
	end

	function UI.Video:show()
		self.video.resource:play()
		self.hidden = false
		return self
	end


	UI.Animation = UI:extend()
	function UI.Animation:init(file, x, y, w, h, row, col, frames, wait, looped)
		self:super(x, y)
		self.resource = file and images.Load(file, {w = w or 1, h = h or 1, x = row or 1, y = col or 1})
		self.frame = 1
		self.max_frames = frames
		self.wait = 0
		self.max_wait = wait or 1
		self.looped = looped or false
	end

	function UI.Animation:update(dt)
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

	function UI.Animation:draw()
		images.draw(self.resource, self.frame, self.x, self.y)
	end


	UI.Text = UI:extend()
	function UI.Text:init(text, fnt, x, y, color, align, stroke)
		self:super(x, y)
		self.align = align
		self.stroke = stroke
		self.font = fnt or "default"
		self.color = color or { 0, 0, 0, 1 }
		self:setText(text)
	end

	function UI.Text:roomloaded()
		self:setText()
	end

	function UI.Text:localechanged()
		self:setText()
	end

	function UI.Text:setText(new_text)
		if type(new_text) == "string" then
			self.text = new_text
		elseif type(new_text) == "table" then
			self.text = new_text.text
			self.key = new_text.key
		elseif self.key then
			local temp = i18n(self.key)
			self.text = temp and temp.text
		else
			self.text = self.text or ""
		end
		local font = fonts.list[self.font]
		if font and self.text then
			self.width = font:getWidth(self.text)
			self.height = font:getHeight(self.text)
		end
	end

	function UI.Text:draw()
		fonts.print(self.text, self.x, self.y, self.align, self.font, self.stroke, self.width, self.color)
	end


	UI.Button = UI:extend()
	function UI.Button:init(text, x, y, w, h, ox, oy, bg, use_mouse)
		self:setText( type(text) == "string" and UI.Text:new(text) or text )
		self:super(x, y, { self.text })
		self.ox = ox or 0
		self.oy = oy or 0
		self.w = w or self.text.width or 1
		self.h = h or self.text.height or 1
		self.background = type(bg) == "string" and images.Load(bg) or bg
		self.use_mouse = use_mouse and true or false
		self.hover = false
		self.clicked = false
	end

	function UI.Button:mousemoved(x, y, dx, dy)
		if not self.use_mouse then return end
		local mx = (x + dx - self.ox) / core.scalex
		local my = (y + dy - self.oy) / core.scaley
		self.hover = mx > self.x and mx < self.x + self.w and my > self.y and my < self.y + self.h
		self.clicked = self.clicked and self.hover
	end

	function UI.Button:useMouse(value)
		self.use_mouse = value and true or false
		return self
	end

	function UI.Button:update(dt)
		-- hook
	end

	function UI.Button:click(x, y, button)
		-- hook
	end

	function UI.Button:roomloaded()
		self.text:localechanged()
	end

	function UI.Button:localechanged()
		self.text:localechanged()
	end

	function UI.Button:setText(new_text)
		if type(new_text) == "string" then
			self.text:setText(new_text)
		elseif not self.text and new_text:isTypeOf(UI.Text) then
			self.text = new_text:on("setText", function (text)
				self.w = text.width or 1
				self.h = text.height or 1
			end)
		end
	end

	function UI.Button:mousepressed(x, y, button, istouch, presses)
		x = (x - self.ox) / core.scalex
		y = (y - self.oy) / core.scaley
		self.clicked = self.use_mouse and x > self.x and x < self.x + self.w and y > self.y and y < self.y + self.h
		if self.clicked then
			self:click(x, y, button)
		end
	end

	function UI.Button:draw()
		if self.background then
			images.draw(self.background, 0, self.x, self.y)
		end

		if self.text then
			self.text.x = self.x + self.ox
			self.text.y = self.y + self.oy
			-- self.text:draw()
		end
	end


	UI.List = UI:extend()
	function UI.List:init(x, y, childs, horizontal)
		self:super(x, y, childs)
		self.cursor = 1
		self.horizontal = horizontal or false
 	end

 	function UI.List:keypressed(key)
 		local size = #self.childs

 		local controls = settings.controls
 		for i = 1, #controls do

 			if self.horizontal then
	 			if key == controls[i].left then
	 				local old = self.childs[self.cursor]
	 				self.cursor = self.cursor > 1 and self.cursor - 1 or size
	 				return self:change(self.childs[self.cursor], old)
	 			elseif key == controls[i].right then
	 				local old = self.childs[self.cursor]
	 				self.cursor = self.cursor < size and self.cursor + 1 or 1
	 				return self:change(self.childs[self.cursor], old)
	 			end
	 		else
	 			if key == controls[i].up then
	 				local old = self.childs[self.cursor]
	 				self.cursor = self.cursor > 1 and self.cursor - 1 or size
	 				return self:change(self.childs[self.cursor], old)
	 			elseif key == controls[i].down then
	 				local old = self.childs[self.cursor]
	 				self.cursor = self.cursor < size and self.cursor + 1 or 1
	 				return self:change(self.childs[self.cursor], old)
	 			end
	 		end

 			if key == controls[i].attack and self.childs[self.cursor].click then
 				return self.childs[self.cursor]:click(nil, nil, 1)
 			end
 		end
 	end

 	function UI.List:change(new, old)
 		old.hover = false
 		new.hover = true
 	end

 	function UI.List:update(dt)
 		self.childs[self.cursor].hover = true
 	end

return UI