local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'EntityManager works only with l2df v1.0 and higher')

local EventManager = core.import 'core.manager.event'

local Manager = { canvas, scalex, scaley }

	function Manager:init()

		EventManager:subscribe("resize", self.resize, nil, self)
		EventManager:subscribe("draw", self.resize, nil, self)

		self.resX = 1280
		self.resY = 720
		self.gameW, self.gameH = love.window.getMode()

		print(self.gameW)
	end

	function Manager:resize(w,h)
		self.gameW, self.gameH = w, h
		print(self.gameW)
	end

	function Manager:draw()
		love.graphics.rectangle("fill", 10, 10, 100, 30)
		-- body
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