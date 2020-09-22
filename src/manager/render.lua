--- Render manager
-- @classmod l2df.manager.render
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'RenderManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local gamera = core.import 'external.gamera'

local rad = math.rad
local min = math.min
local max = math.max
local atan = math.atan
local sign = helper.sign
local floor = math.floor
local round = helper.round
local default = helper.notNil
local tsort = table.sort
local tremove = table.remove
local unpack = table.unpack or _G.unpack
local loveSetMode = love.window.setMode
local loveGetMode = love.window.getMode
local loveDraw = love.graphics.draw
local loveClear = love.graphics.clear
local lovePrintf = love.graphics.printf
local loveGetColor = love.graphics.getColor
local loveSetColor = love.graphics.setColor
local loveGetLineWidth = love.graphics.getLineWidth
local loveSetLineWidth = love.graphics.setLineWidth
local loveSetCanvas = love.graphics.setCanvas
local loveNewCanvas = love.graphics.newCanvas
local loveSetDefaultFilter = love.graphics.setDefaultFilter
local loveCircle = love.graphics.circle
local loveEllipse = love.graphics.ellipse
local loveRect = love.graphics.rectangle

local PI_2 = 2 / math.pi

local lights = { }
local layers = { }
local layers_map = { }

local Manager = { z = { { } }, shadows = 2, DEBUG = os.getenv('L2DF_DEBUG') or false }

	--- Configure @{l2df.manager.render}
	-- @param table kwargs                         Table containing all settings parameters
	-- @param[opt=640] number kwargs.width         Width of the game in pixels. It's independent from the width of the screen / window
	-- @param[opt=360] number kwargs.height        Height of the game in pixels. It's independent from the height of the screen / window
	-- @param[opt=1] number kwargs.depth           Default depth of the worlds. Required for correct z-ordering
	-- @param[opt=1] number kwargs.cellsize        Size of the one depth cell in pixels. Required for correct z-ordering
	-- @param[opt=2] number kwargs.shadows         Quality of shadows (number from 0 to 2)
	-- @param[opt='nearest'] string kwargs.filter  Filter to use for up/downscaling textures. Can be 'nearest' or 'linear'
	-- @param[opt] boolean kwargs.ratio            Set to true to keep game's aspect ratio and have black borders if it doesn't match current window size
	-- @param[opt] boolean kwargs.fullscreen       Set to true to use fullscreen mode
	-- @param[opt] boolean kwargs.resizable        Set to true to allow user manually resize game window
	-- @param[opt] boolean kwargs.vsync            Set to true to use vertical synchronization
	-- @return l2df.manager.render
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		kwargs.width = kwargs.width or self.width or 640
		kwargs.height = kwargs.height or self.height or 360
		kwargs.depth = kwargs.depth or self.depth or 1

		local width, height, info = loveGetMode()
		self.DEBUG = default(kwargs.debug, self.DEBUG)
		self.vsync = default(kwargs.vsync, info.vsync == 1)
		self.resizable = default(kwargs.resizable, info.resizable)
		self.fullscreen = default(kwargs.fullscreen, info.fullscreen)
		self.ratio = default(kwargs.ratio, not not self.ratio)
		self.filter = kwargs.filter or self.filter or 'nearest'
		self.shadows = kwargs.shadows or self.shadows or 2
		self.cellsize = kwargs.cellsize or 1
		self.background = kwargs.background or { 0, 0, 0, 1 }
		loveSetDefaultFilter(self.filter, self.filter)
		loveSetMode(width, height, {
			resizable = not not self.resizable,
			fullscreen = not not self.fullscreen,
			vsync = self.vsync and 1 or 0,
			minwidth = width,
			minheight = height,
		})
		self:setResolution(kwargs.width, kwargs.height, kwargs.depth)
		return self
	end

	---
	-- @param number width
	-- @param number height
	function Manager:resize(width, height)
		self.scalex, self.scaley = width / self.width, height / self.height
		self.offsetx, self.offsety = 0, 0
		if self.ratio then
			self.scalex = min(self.scalex, self.scaley)
			self.scaley = self.scalex
			self.offsetx = (width - self.width * self.scalex) * 0.5
			self.offsety = (height - self.height * self.scaley) * 0.5
		end
		self.INVALIDATED = true
	end

	--- Set up game space
	-- @param number width   Width of the game. It's independent from the width of the screen / window
	-- @param number height  Height of the game. It's independent from the height of the screen / window
	-- @param number depth   Default depth of the worlds. Required for correct z-ordering
	function Manager:setResolution(width, height, depth)
		self.width, self.height, self.depth = width, height, depth
		self.canvas = loveNewCanvas(width, height)
		self.z = { }
		for i = 1, depth do
			self.z[i] = { }
		end
		for i = 1, #layers do
			local camera = layers[i].camera
			if camera then
				camera:setWindow(0, 0, width, height)
			end
		end
		self:resize(loveGetMode())
	end

	local function sortByIndex(a, b)
		return (a.index < b.index)
	end

	--- Add new layer for drawings
	-- @param string name
	-- @param table kwargs
	-- @param[opt] number kwargs.x
	-- @param[opt] number kwargs.y
	-- @param[opt] number kwargs.width
	-- @param[opt] number kwargs.height
	-- @param[opt] number kwargs.depth
	-- @param[opt] number kwargs.index
	-- @param[opt] table kwargs.background
	-- @param[opt] boolean kwargs.camera
	function Manager:addLayer(name, kwargs)
		if not name then return end

		kwargs = kwargs or { }
		kwargs.x = kwargs.x or 0
		kwargs.y = kwargs.y or 0
		kwargs.width = kwargs.width or self.width
		kwargs.height = kwargs.height or self.height
		kwargs.depth = kwargs.depth or self.depth
		kwargs.index = kwargs.index or (#layers > 0 and layers[#layers].index or 0)
		kwargs.background = kwargs.background or { 0, 0, 0, 255 }

		local layer = {
			name = name,
			background = {
				(kwargs.background[1] or 0) / 255,
				(kwargs.background[2] or 0) / 255,
				(kwargs.background[3] or 0) / 255,
				(kwargs.background[4] or 0) / 255,
			},
			x = kwargs.x,
			y = kwargs.y,
			width = kwargs.width,
			height = kwargs.height,
			index = kwargs.index,
			tracking = { },
			camera = kwargs.camera and gamera.new(self.width, self.height) or nil,
			canvas = loveNewCanvas(kwargs.width, kwargs.height),
			z = { },
			INVALIDATED = true
		}
		for i = 1, kwargs.depth do
			layer.z[i] = { }
		end
		layers[layers_map[name] or #layers + 1] = layer
		tsort(layers, sortByIndex)
		for i = 1, #layers do
			layers_map[layers[i].name] = i
		end
		self.INVALIDATED = true
	end

	---
	-- @param string name
	-- @param[opt] number width
	-- @param[opt] number height
	-- @param[opt] number depth   Depth of the world. Required for correct z-ordering
	-- @param[opt=1] number zoom
	function Manager:updateLayerWorld(name, width, height, depth, zoom)
		if not (name and layers_map[name]) then return end
		local layer = layers[layers_map[name]]
		local camera = layer.camera
		layer.width, layer.height = width or layer.width, height or layer.height
		if depth and depth ~= layer.depth then
			layer.z = { }
			for i = 1, depth do
				layer.z[i] = { }
			end
			layer.depth = depth
		end
		if camera then
			camera.zoom = zoom or camera.zoom
			camera:setWorld(0, 0, layer.width, layer.height)
		end
		layer.INVALIDATED = true
		self.INVALIDATED = true
	end

	function Manager:removeLayer(name)
		if not layers_map[name] then return end
		tremove(layers, layers_map[name])
		layers_map[name] = nil
	end

	local function clearLayer(layer)
		loveSetCanvas(layer.canvas)
		loveClear(unpack(layer.background))
		local drawables, invalidate = layer.z, false
		for i = 1, #drawables do
			for j = #drawables[i], 1, -1 do
				drawables[i][j] = nil
				invalidate = true
			end
		end
		if layer.camera then
			local tracking = layer.tracking
			for i = #tracking, 1, -1 do
				tracking[i] = nil
			end
			layer.camera:setScale(1)
		end
		layer.INVALIDATED = invalidate
		-- loveSetCanvas()
	end

	--- Request layer's camera to track specific point
	-- @param string layer
	-- @param[opt] number x
	-- @param[opt] number y
	-- @param[opt=0] number ox
	-- @param[opt=0] number oy
	-- @param[opt=0] number kx
	-- @param[opt=0] number ky
	-- @param[opt=1] number priority
	function Manager:track(layer, x, y, ox, oy, kx, ky, priority)
		layer = layers[layers_map[layer or 0] or 0]
		if not layer or not layer.camera then return end
		layer.tracking[#layer.tracking + 1] = {
			x = x or layer.camera.x, y = y or layer.camera.y,
			ox = ox or 0, oy = oy or 0,
			kx = kx or 0, ky = ky or 0,
			p = priority or 1
		}
	end

	-- @param table light
	function Manager:addLight(light)
		light.f = light.f or 4
		light.ground = light.ground or 0
		lights[#lights + 1] = light
	end

	--- Push element to render chain
	-- @param table element
	-- @param[opt] string element.layer
	function Manager:draw(element)
		if not element then return end

        local layer = layers[layers_map[element.layer or 0] or 0]
        local z = layer and layer.z or self.z
		local index = floor(((element.z or 0) + (element.d or 0)) / self.cellsize) + 1
		index = index > 0 and index < #z and index or 1
		z[index][#z[index] + 1] = element
		if layer then
			layer.INVALIDATED = true
		end
		self.INVALIDATED = true
	end

	--- Clear all layers, render chain, trackers and reset cameras
	function Manager:clear()
		for i = #lights, 1, -1 do
			lights[i] = nil
		end
		for i = 1, #layers do
			clearLayer(layers[i])
		end
		clearLayer(self)
		loveSetCanvas()
	end

	local function setAlpha(r, g, b, a, i)
		loveSetColor(r * i, g * i, b * i, a)
	end

	local function render(x, y, w, h, layer, clear)
		loveSetCanvas(layer.canvas)
		if clear then
			loveClear(unpack(layer.background))
		end
		local input, r1, g1, b1, a1, r2, g2, b2, a2, bwidth
		local drawables = layer.z
		for i = 1, #drawables do
			for j = 1, #drawables[i] do
				input = drawables[i][j]
				r1, g1, b1, a1 = loveGetColor()
				bwidth = loveGetLineWidth()
				-- Draw shadows
				if input.shadow and Manager.shadows > 0 then
					local object = Manager.shadows > 1 and input.object or nil
					local x, y, z, sx, sy = input.x or 0, input.y or 0, input.z or 0, input.sx or 1, input.sy or 1
					if not object then
						local r = input.rad or min(input.ox or 1, input.oy or 1)
						loveSetColor(0, 0, 0, 0.5)
						loveEllipse('fill', round(x), round(z), r * (sx or 1), r * (sy or 1) * 0.25)
					else
						local ox, oy = input.ox or 0, input.oy or 0
						for i = 1, #lights do
							local light = lights[i]
							if light.shadow then
								local dx, dy, dz = light.x - x, light.y - y, light.z - z
								local distance = dx * dx + dy * dy + dz * dz
								local squared_r = light.r * light.r
								if distance < squared_r then
									local sz = sign(dz)
									local dr = 1 - atan(distance / (squared_r - distance) * (light.f - 1)) * PI_2
									loveSetColor(0, 0, 0, dr)
									dr = dr * (1 - atan(dy / (light.r - dy)) * PI_2)
									dy = y * sz * (1 - dr)
									local sy = sy * sz * dr * 2
									sz = sz * dr * dx / dz * sx -- * sign(sx)
									if input.quad then
										loveDraw(object, input.quad, round(x), round(z - dy), 0, sx, sy, ox, oy, sz)
									else
										loveDraw(object, round(x), round(z - dy), 0, sx, sy, ox, oy, sz)
									end
								end
							end
						end
					end
				end
				-- Set render color
				if input.color then
					r2, g2, b2, a2 = input.color[1] or 1, input.color[2] or 1, input.color[3] or 1, input.color[4] or 1
					loveSetColor(r2, g2, b2, a2)
				end
				-- Set border width
				if input.border then
					loveSetLineWidth(input.border)
				end
				-- Accept object draw request
				if input.object and input.object.typeOf and input.object:typeOf('Drawable') then
					if input.quad then
						loveDraw(input.object, input.quad, round(input.x), round(input.z - input.y), rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
					else
						loveDraw(input.object, round(input.x), round(input.z - input.y), rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
					end
				-- Accept rectangle draw request
				elseif input.rect then
					loveRect(input.rect, round(input.x), round(input.y), input.w or 1, input.h or 1, input.rx, input.ry)
				-- Accept cube draw request
				elseif input.cube then
					setAlpha(r2, g2, b2, a2, 0.3)
					loveRect('fill', input.x, input.z - input.y + input.d, input.w, input.h)

					setAlpha(r2, g2, b2, a2, 1)
					loveRect('line', input.x, input.z - input.y + input.d, input.w, input.h)

					setAlpha(r2, g2, b2, a2, 0.5)
					loveRect('fill', input.x, input.z - input.y, input.w, input.d)

					setAlpha(r2, g2, b2, a2, 1)
					loveRect('line', input.x, input.z - input.y, input.w, input.d)
				-- Accept circle draw request
				elseif input.circle then
					loveCircle(input.circle, round(input.x), round(input.z - input.y), input.r or 4)
				-- Accept text draw request
				elseif input.text and type(input.text) == 'string' then
					lovePrintf(input.text, input.font, input.x, input.y, input.limit, input.align, rad(input.r), input.sx, input.sy, input.ox, input.oy, input.kx, input.ky)
				end
				-- Restore color and border
				loveSetColor(r1, g1, b1, a1)
				loveSetLineWidth(bwidth)
			end
		end
	end

	--- Render all added drawables depepending on their type 
	function Manager:render()
		if self.INVALIDATED then
			for i = 1, #layers do
				local layer = layers[i]
				if layer.INVALIDATED then
					local camera = layer.camera
					if camera then
						local tracking = layer.tracking
						if #tracking > 0 then
							local t = tracking[1]
							local x, y, p = t.x, t.y, t.p
							local x1, y1 = x - t.ox - t.kx, y - t.ky
							local x2, y2 = x + t.ox + t.kx, y + t.oy + t.ky
							for i = 2, #tracking do
								t = tracking[i]
								local k, dk = p + t.p, 1 / (p + t.p)
								x1, y1 = min(x1, t.x - t.ox - t.kx), min(y1, t.y - t.ky)
								x2, y2 = max(x2, t.x + t.ox + t.kx), max(y2, t.y + t.oy + t.ky)
								x, y, p = (x * p + t.x * t.p) * dk, (y * p + t.y * t.p) * dk, k
							end
							local s, l, t, w, h = camera.zoom, camera:getVisible(camera.zoom)
							camera:setScale(min(s, w / (x2 - x1) * s, h / (y2 - y1) * s))
							camera:setPosition(x, y)
						end
						camera:draw(render, layer, true)
					else
						render(layer.x, layer.y, layer.width, layer.height, layer, true)
					end
					layer.INVALIDATED = false
				end
			end
			loveSetCanvas(self.canvas)
			loveClear(unpack(self.background))
			for i = 1, #layers do
				local layer = layers[i]
				loveDraw(layer.canvas, layer.x, layer.y)
			end
			render(0, 0, self.width, self.height, self)
			loveSetCanvas()
			self.INVALIDATED = false
		end
		loveDraw(self.canvas, self.offsetx, self.offsety, 0, self.scalex, self.scaley)
	end

return setmetatable(Manager, { __call = Manager.init })