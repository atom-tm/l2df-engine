--- Render manager
-- @classmod l2df.manager.render
-- @author Abelidze, Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'RenderManager works only with l2df v1.0 and higher')

local rad = math.rad
local loveDraw = love.graphics.draw
local loveClear = love.graphics.clear
local lovePrintf = love.graphics.printf
local loveGetColor = love.graphics.getColor
local loveSetColor = love.graphics.setColor
local loveSetCanvas = love.graphics.setCanvas
local loveNewCanvas = love.graphics.newCanvas

local layers = {
	UI = { }
}

local drawables = { }

local Manager = { canvas = nil, scalex = nil, scaley = nil }

	function Manager:init()
		self.resX, self.resY = 640, 360
		self.gameW, self.gameH = love.window.getMode()
		self.scaleX, self.scaleY = self.gameW / self.resX, self.gameH / self.resY

		self.canvas = loveNewCanvas(self.resX, self.resY)
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

	function Manager:resize(w, h)
		self.gameW, self.gameH = w, h
		self.scaleX, self.scaleY = self.gameW / self.resX, self.gameH / self.resY
	end

	function Manager:layersClear()
		loveSetCanvas(self.canvas)
		loveClear()
		loveSetCanvas()
	end

	function Manager:clear()
		for i = 1, #drawables do
			for j = #drawables[i], 1, -1 do
				drawables[i][j] = nil
			end
		end
		self:layersClear()
	end

	function Manager:draw()
		loveSetCanvas(self.canvas)
		self:render()
		loveSetCanvas()
		loveDraw(self.canvas, 0, 0, 0, self.scaleX, self.scaleY)
	end

	function Manager:render()
		local input, r, g, b, a
		for i = 1, #drawables do
			for j = 1, #drawables[i] do
				input = drawables[i][j]
				r, g, b, a = loveGetColor()
				loveSetColor(input.color[1] or 1, input.color[2] or 1, input.color[3] or 1, input.color[4] or 1)
				if input.object and input.object.typeOf and input.object:typeOf('Drawable') then
					if input.quad then
						loveDraw(input.object, input.quad, input.x, input.y, rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
					else
						loveDraw(input.object, input.x, input.y, rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
					end
					love.graphics.circle('fill', input.x, input.y, 8)
				elseif input.text and type(input.text) == 'string' then
					lovePrintf(input.text, input.font, input.x, input.y, input.limit, input.align, rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
				end
				loveSetColor(r, g, b, a)
			end
		end
	end

return Manager