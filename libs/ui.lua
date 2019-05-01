local UI = object:extend()

function UI:init(x,y)
	self.x = x or 10
	self.y = y or 0
end

UI.Image = UI:extend()
UI.Text = UI:extend()
UI.Button = UI:extend()


function UI.Image:init(x,y,file)
	UI:init(x,y)
	self.resource = file and image.Load(file) or nil
end

function UI.Text:init(x,y,content)
	UI:init(x,y)
	self.content = content
end

function UI.Text:draw()
	font.print(self.content, self.x, self.y)
end

return UI