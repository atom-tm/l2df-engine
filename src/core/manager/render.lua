local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EntityManager works only with l2df v1.0 and higher')

local EventManager = core.import 'core.manager.event'

local layers = {
	UI = {}
}

local drawables = { }
local prints = { }

local Manager = { canvas, scalex, scaley }

	function Manager:init()
		EventManager:subscribe("resize", self.resize, nil, self)
		EventManager:subscribe("draw", self.draw, nil, self)

		self.resX, self.resY = 640, 360
		self.gameW, self.gameH = love.window.getMode()
		self.scaleX, self.scaleY = self.gameW/self.resX, self.gameH/self.resY

		self.canvas = love.graphics.newCanvas(self.resX, self.resY)
		self:setMaxIndex(10)
	end


	function Manager:setMaxIndex(int)
		drawables = { }
		prints = { }
		for i = 1, int do
			drawables[i] = { }
			prints[i] = { }
		end
	end


	function Manager:add(object, x, y, index)
		if not object then return end
		local target = nil

		if object[1].typeOf and object[1]:typeOf("Drawable") then target = drawables
		elseif type(object[1]) == "string" then target = prints
		else return end

		index = index or 1
		x = x or 0
		y = y or 0
		target[index][#target[index] + 1] = { object, x, y }

	end


	function Manager:resize(w,h)
		self.gameW, self.gameH = w, h
		self.scaleX, self.scaleY = self.gameW/self.resX, self.gameH/self.resY
		print(self.scaleX)
		print(self.scaleY)
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
		for i = 1, #drawables do
			for j = 1, #drawables[i] do
				local e = drawables[i][j]
				if e[1][2] then
					love.graphics.draw(e[1][1], e[1][2], e[2], e[3])
				else
					love.graphics.draw(e[1][1], e[2], e[3])
				end
			end
			drawables[i] = { }
			for j = 1, #prints[i] do
				local t = prints[i][j]
				love.graphics.printf(t[1], t[2], t[3], 100)
			end
			prints[i] = { }
		end
	end


	function Manager:generateQuad(resourse, x, y, w, h)
		if not (resourse and resourse.typeOf and resourse:typeOf("Drawable")) then return end
		return { resourse, love.graphics.newQuad(x,y,w,h,resourse:getDimensions()) }
	end


return Manager


	--[[function Manager:reloadLayers(w, h)
		layers_map = {}
		self.canvas = loveNewCanvas(w, h)
		for i = 1, #layers do
			layers_map[layers[i] = loveNewCanvas(w, h)
		end
	end]]

	--[[function Manager:reloadGraphics( ... )
		math.randomseed(love.timer.getTime())
		love.graphics.setDefaultFilter("nearest", "nearest")

		settings.gameWidth = settings.private.resolutions[settings.global.resolution].width
		settings.gameHeight = settings.private.resolutions[settings.global.resolution].height

		love.window.setMode(settings.gameWidth, settings.gameHeight, {
			fullscreen = settings.graphic.fullscreen,
			vsync = settings.graphic.vsync,
			msaa = 0,
			depth = 0,
			minwidth = settings.private.resolutions[1].width,
			minheight = settings.private.resolutions[1].height,
			resizable = true
		})

		if settings.graphic.fullscreen then
			settings.global.width, settings.global.height = love.window.getMode()
		else
			settings.global.width, settings.global.height = settings.gameWidth, settings.gameHeight
			self:resize(settings.gameWidth, settings.gameHeight)
		end
	end]]


	--[[function Manager:resize(w, h)
		settings.global.width = w
		settings.global.height = h
		self.scalex = w / settings.gameWidth
		self.scaley = h / settings.gameHeight
	end]]

	--[[function Manager:clearZIndex(n)
		for i = 1, n do
			z_index[i] = {}
		end
	end







	function Manager:unsubscribeById(event, id)
		return event and id and subscribers[event]:removeById(id)
	end]]