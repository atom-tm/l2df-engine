local __DIR__ = (...) .. "."
gamera		= require(__DIR__ .. "external.gamera")
json 		= require(__DIR__ .. "external.json")
helper 		= require(__DIR__ .. "helper")

--battle		= require(__DIR__ .. "battle")
---------------------------------------------
camera = nil
locale = nil
---------------------------------------------
local min_dt, next_time

local core = { version = "1.0" }

	core.settings	= require(__DIR__ .. "settings")
	-- core.resources	= require(__DIR__ .. "resources")
	-- core.data		= require(__DIR__ .. "data")
	core.i18n		= require(__DIR__ .. "i18n")

	core.font		= require(__DIR__ .. "fonts")
	core.sound		= require(__DIR__ .. "sounds")
	core.image		= require(__DIR__ .. "images")
	core.video		= require(__DIR__ .. "videos")
	core.ui			= require(__DIR__ .. "ui")
	core.rooms		= require(__DIR__ .. "rooms")

	core.canvasW = 1
	core.canvasH = 1

	function core:init(filepath)
		local settings = self.settings.global
		self.settings:load(filepath)
		self.sound:setConfig(settings)
		self.ui:setControls(self.settings.controls)

		-- -- FPS Limiter initialize --
		min_dt = 1 / self.settings.graphic.fpsLimit
		next_time = love.timer.getTime()
		-- ----------------------------

		helper.hook(self.i18n, "setLocale", function (_, key) self.settings.lang = key end, self.i18n)
		helper.hook(love, "update", self.update, self)
		helper.hook(love, "draw", self.draw, self)
		helper.hook(love, "resize", self.resize, self)

		self.rooms:init(settings.rooms_path, settings.startRoom)
		self.settings:apply(self)
	end

	function core:update()
		-- Mouse position calculation --
		-- local x, y = love.mouse.getPosition( )
		-- settings.mouseX = x * (settings.gameWidth / settings.global.width)
		-- settings.mouseY = y * (settings.gameHeight / settings.global.height)

		-- FPS Limiter --
		next_time = next_time + min_dt
	end

	function core:draw()
		if self.canvas then
			love.graphics.draw(self.canvas, 0, 0, 0, self.canvasW, self.canvasH)
		end

		-- FPS Limiter working --
		local cur_time = love.timer.getTime()
		if next_time <= cur_time then
			next_time = cur_time
			return
		end
		love.timer.sleep(next_time - cur_time)
	end

	function core:resize(w, h)
		self.settings.global.width = w
		self.settings.global.height = h

		self.canvasW = w / self.settings.gameWidth
		self.canvasH = h / self.settings.gameHeight
	end

return core