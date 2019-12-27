--- Render manager
-- @classmod l2df.core.manager.render
-- @author Abelidze, Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'RenderManager works only with l2df v1.0 and higher')

local EventManager = core.import 'core.manager.event'
local ResourceManager = core.import 'core.manager.resource'
local rad = math.rad

local layers = {
	UI = { }
}

local drawables = { }

local Manager = { canvas = nil, scalex = nil, scaley = nil }

	function Manager:init()
		EventManager:subscribe('resize', self.resize, nil, self)
		EventManager:subscribe('update', self.clear, nil, self)
		EventManager:subscribe('draw', self.draw, nil, self)

		self.resX, self.resY = 640, 360
		self.gameW, self.gameH = love.window.getMode()
		self.scaleX, self.scaleY = self.gameW / self.resX, self.gameH / self.resY

		self.canvas = love.graphics.newCanvas(self.resX, self.resY)
		self:setMaxIndex(10)
	end

	function Manager:setMaxIndex(index)
		drawables = { }
		for i = 1, index do
			drawables[i] = { }
		end
	end

	function Manager:add(input)
		if not (input or input.object) then return end
		local index = input.index > 0 and input.index < #drawables and input.index or 1
		drawables[index][#drawables[index] + 1] = input
	end

	function Manager:resize(w,h)
		self.gameW, self.gameH = w, h
		self.scaleX, self.scaleY = self.gameW / self.resX, self.gameH / self.resY
	end

	function Manager:clear()
		for i = 1, #drawables do
			for j = #drawables[i], 1, -1 do
				drawables[i][j] = nil
			end
		end
	end

	function Manager:layersClear()
		love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		love.graphics.setCanvas()
	end

	function Manager:draw()
		self:layersClear()
		love.graphics.setCanvas(self.canvas)
		self:render()
		love.graphics.setCanvas()
		love.graphics.draw(self.canvas, 0, 0, 0, self.scaleX, self.scaleY)
	end

	function Manager:render()
		local input, r,g,b,a
		for i = 1, #drawables do
			for j = 1, #drawables[i] do
				input = drawables[i][j]
				r, g, b, a = love.graphics.getColor()
				love.graphics.setColor(input.color[1] or 1, input.color[2] or 1, input.color[3] or 1, input.color[4] or 1)
				if input.object then
					input.object = ResourceManager:get(input.object)
					if input.object and input.object.typeOf and input.object:typeOf('Drawable') then
						print(input.object)
						love.graphics.draw(input.object, input.quad, input.x, input.y, rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
					end
				elseif input.text and type(input.text) == "string" then
					love.graphics.printf(input.text, input.font, input.x, input.y, input.limit, input.align, rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
				end
				love.graphics.setColor(r, g, b, a)
			end
		end
	end

	function Manager:generateQuad(x, y, w, h)
		if not (w and h) then return end
		x = x or 1
		y = y or 1
		return love.graphics.newQuad(x,y,w,h,x*w,y*h)
	end

return Manager