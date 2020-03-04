--- Render manager
-- @classmod l2df.manager.render
-- @author Abelidze, Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'RenderManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local rad = math.rad
local floor = math.floor
local round = helper.round
local loveDraw = love.graphics.draw
local loveClear = love.graphics.clear
local lovePrintf = love.graphics.printf
local loveGetColor = love.graphics.getColor
local loveSetColor = love.graphics.setColor
local loveSetCanvas = love.graphics.setCanvas
local loveNewCanvas = love.graphics.newCanvas
local loveCircle = love.graphics.circle
local loveRect = love.graphics.rectangle

local function setAlpha(r, g, b, a, i)
	loveSetColor(r * i, g * i, b * i, a)
end

local layers = {
	UI = { }
}

local drawables = { { } }

local Manager = { canvas = nil, scalex = nil, scaley = nil, DEBUG = os.getenv('L2DF_DEBUG') or false }

	function Manager:init(zlevels, cellsize)
		self.resX, self.resY = 640, 360
		self.gameW, self.gameH = love.window.getMode()
		self.scaleX, self.scaleY = self.gameW / self.resX, self.gameH / self.resY
		self.cellsize = cellsize or 1

		self.canvas = loveNewCanvas(self.resX, self.resY)
		self:setMaxZIndex(zlevels or 10)
	end

	function Manager:setMaxZIndex(index)
		drawables = { }
		for i = 1, index do
			drawables[i] = { }
		end
	end

	function Manager:add(input)
		if not input then return end

		local levels = #drawables
		local index = floor(((input.z or 0) + (input.l or 0)) / self.cellsize) + 1
		index = index > 0 and index < #drawables and index or 1
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
		local input, r1, g1, b1, a1, r2, g2, b2, a2
		for i = 1, #drawables do
			for j = 1, #drawables[i] do
				input = drawables[i][j]
				r1, g1, b1, a1 = loveGetColor()
				if input.color then
					r2, g2, b2, a2 = input.color[1] or 1, input.color[2] or 1, input.color[3] or 1, input.color[4] or 1
					loveSetColor(r2, g2, b2, a2)
				end
				if input.object and input.object.typeOf and input.object:typeOf('Drawable') then
					if input.quad then
						loveDraw(input.object, input.quad, round(input.x), round(input.y + input.z), rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
					else
						loveDraw(input.object, round(input.x), round(input.y + input.z), rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
					end
				elseif input.rect then
					loveRect(input.rect, round(input.x), round(input.y), input.w or 1, input.h or 1)
				elseif input.cube then
					setAlpha(r2, g2, b2, a2, 0.3)
					loveRect('fill', input.x, input.y + input.z + input.l, input.w, input.h)

					setAlpha(r2, g2, b2, a2, 1)
					loveRect('line', input.x, input.y + input.z + input.l, input.w, input.h)

					setAlpha(r2, g2, b2, a2, 0.5)
					loveRect('fill', input.x, input.y + input.z, input.w, input.l)

					setAlpha(r2, g2, b2, a2, 1)
					loveRect('line', input.x, input.y + input.z, input.w, input.l)
				elseif input.circle then
					loveCircle(input.circle, round(input.x), round(input.y + input.z), input.r or 4)
				elseif input.text and type(input.text) == 'string' then
					lovePrintf(input.text, input.font, input.x, input.y, input.limit, input.align, rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
				end
				loveSetColor(r1, g1, b1, a1)
			end
		end
	end

return Manager