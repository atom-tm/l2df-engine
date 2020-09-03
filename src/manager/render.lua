--- Render manager
-- @classmod l2df.manager.render
-- @author Abelidze, Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'RenderManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local gamera = core.import 'external.gamera'

local rad = math.rad
local min = math.min
local max = math.max
local floor = math.floor
local round = helper.round
local loveDraw = love.graphics.draw
local loveClear = love.graphics.clear
local lovePrintf = love.graphics.printf
local loveGetColor = love.graphics.getColor
local loveSetColor = love.graphics.setColor
local loveSetCanvas = love.graphics.setCanvas
local loveNewCanvas = love.graphics.newCanvas
local loveSetDefaultFilter = love.graphics.setDefaultFilter
local loveCircle = love.graphics.circle
local loveEllipse = love.graphics.ellipse
local loveRect = love.graphics.rectangle

local function setAlpha(r, g, b, a, i)
	loveSetColor(r * i, g * i, b * i, a)
end

local layers = {
	UI = { }
}

local camera = nil
local tracking = { }
local drawables = { { } }

local Manager = { canvas = nil, scalex = nil, scaley = nil, shadow_level = 2, DEBUG = os.getenv('L2DF_DEBUG') or false }

	function Manager:init(width, height, depth, cellsize)
		camera = gamera.new(width or 640, height or 360)
		self.cellsize = cellsize or 1
		self:setGameSize(width or 640, height or 360, depth or 10)
		self:resize()
		loveSetDefaultFilter('nearest', 'nearest')
	end

	function Manager:setGameSize(width, height, depth)
		self.game_width = width
		self.game_height = height
		self.canvas = loveNewCanvas(self.game_width, self.game_height)
		drawables = { }
		for i = 1, depth do
			drawables[i] = { }
		end
		camera:setWindow(0, 0, width, height)
	end

	function Manager:setWorldSize(width, height, scale)
		camera:setWorld(0, 0, width or self.game_width, height or self.game_height)
		camera:setScale(scale or 1)
	end

	function Manager:track(x, y, ox, oy, kx, ky)
		tracking[#tracking + 1] = {
			x = x or camera.x, y = y or camera.y,
			ox = ox or 0, oy = oy or 0,
			kx = kx or 0, ky = ky or 0
		}
	end

	function Manager:add(input)
		if not input then return end

		local levels = #drawables
		local index = floor(((input.z or 0) + (input.d or 0)) / self.cellsize) + 1
		index = index > 0 and index < #drawables and index or 1
		drawables[index][#drawables[index] + 1] = input
	end

	function Manager:resize(w, h)
		self.resx, self.resy, self.info = love.window.getMode()
		self.scalex, self.scaley = self.resx / self.game_width, self.resy / self.game_height
		self.vsync = true --self.info.vsync == 1
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
		for i = #tracking, 1, -1 do
			tracking[i] = nil
		end
		self:layersClear()
		camera:setScale(1)
	end

	function Manager:draw()
		if #tracking > 0 then
			local x, y = tracking[1].x, tracking[1].y
			local x1, y1, x2, y2 = x, y, x, y
			for i = 2, #tracking do
				local tracked = tracking[i]
				x1, y1 = min(x1, tracked.x - tracked.ox - tracked.kx), min(y1, tracked.y - tracked.ky)
				x2, y2 = max(x2, tracked.x + tracked.ox + tracked.kx), max(y2, tracked.y + tracked.oy + tracked.ky)
				x, y = (x + tracked.x) / 2, (y + tracked.y - tracked.oy) / 2
			end
			local s, l, t, w, h = camera:getScale(), camera:getVisible()
			camera:setScale(min(s, w / (x2 - x1) * s, h / (y2 - y1) * s))
			camera:setPosition(x, y)
		end
		loveSetCanvas(self.canvas)
		camera:draw(Manager.render)
		loveSetCanvas()
		loveDraw(self.canvas, 0, 0, 0, self.scalex, self.scaley)
	end

	function Manager.render(x, y, w, h)
		local input, r1, g1, b1, a1, r2, g2, b2, a2
		for i = 1, #drawables do
			for j = 1, #drawables[i] do
				input = drawables[i][j]
				r1, g1, b1, a1 = loveGetColor()
				if input.color then
					r2, g2, b2, a2 = input.color[1] or 1, input.color[2] or 1, input.color[3] or 1, input.color[4] or 1
					loveSetColor(r2, g2, b2, a2)
				end
				if input.shadow then
					if Manager.shadow_level < 2 then
						loveEllipse('fill', round(input.x), round(input.z - input.y), input.rx or 4, input.ry or 4)
					elseif input.quad then
						loveDraw(input.shadow, input.quad, round(input.x), round(input.z - input.y), 0, input.sx, input.sy, input.ox, input.oy, input.shear, 0)
					else
						loveDraw(input.shadow, round(input.x), round(input.z - input.y), 0, input.sx, input.sy, input.ox, input.oy, input.shear, 0)
					end
				elseif input.object and input.object.typeOf and input.object:typeOf('Drawable') then
					if input.quad then
						loveDraw(input.object, input.quad, round(input.x), round(input.z - input.y), rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
					else
						loveDraw(input.object, round(input.x), round(input.z - input.y), rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
					end
				elseif input.rect then
					loveRect(input.rect, round(input.x), round(input.y), input.w or 1, input.h or 1)
				elseif input.cube then
					setAlpha(r2, g2, b2, a2, 0.3)
					loveRect('fill', input.x, input.z - input.y + input.d, input.w, input.h)

					setAlpha(r2, g2, b2, a2, 1)
					loveRect('line', input.x, input.z - input.y + input.d, input.w, input.h)

					setAlpha(r2, g2, b2, a2, 0.5)
					loveRect('fill', input.x, input.z - input.y, input.w, input.d)

					setAlpha(r2, g2, b2, a2, 1)
					loveRect('line', input.x, input.z - input.y, input.w, input.d)
				elseif input.circle then
					loveCircle(input.circle, round(input.x), round(input.z - input.y), input.r or 4)
				elseif input.text and type(input.text) == 'string' then
					lovePrintf(input.text, input.font, input.x, input.y, input.limit, input.align, rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
				end
				loveSetColor(r1, g1, b1, a1)
			end
		end
	end

return Manager