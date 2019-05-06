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

l2df = { }

	l2df.version	= 1.0

	l2df.settings	= require(__DIR__ .. "settings")
	-- l2df.resources	= require(__DIR__ .. "resources")
	-- l2df.data		= require(__DIR__ .. "data")
	l2df.i18n		= require(__DIR__ .. "i18n")

	l2df.font		= require(__DIR__ .. "fonts")
	l2df.sound		= require(__DIR__ .. "sounds")
	l2df.image		= require(__DIR__ .. "images")
	l2df.video		= require(__DIR__ .. "videos")
	l2df.ui			= require(__DIR__ .. "ui")
	l2df.rooms		= require(__DIR__ .. "rooms")

	l2df.scalex = 1
	l2df.scaley = 1

	function l2df:init(filepath)
		local settings = self.settings.global
		self.settings:load(filepath)
		self.sound:setConfig(settings)

		-- FPS Limiter initialize --
		min_dt = 1 / self.settings.graphic.fpsLimit
		next_time = love.timer.getTime()
		----------------------------

		helper.hook(self.i18n, "setLocale", function (_, key) self.settings.lang = key end, self.i18n)
		helper.hook(love, "update", self.update, self)
		helper.hook(love, "draw", self.draw, self)
		helper.hook(love, "resize", self.resize, self)

		self.rooms:init()
		self.settings:apply()
	end

	function l2df:update()
		-- Mouse position calculation --
		-- local x, y = love.mouse.getPosition( )
		-- settings.mouseX = x * (settings.gameWidth / settings.global.width)
		-- settings.mouseY = y * (settings.gameHeight / settings.global.height)

		-- FPS Limiter --
		next_time = next_time + min_dt
		----------------------------
	end

	function l2df:draw()
		if self.canvas then
			love.graphics.draw(self.canvas, 0, 0, 0, self.scalex, self.scaley)
		end

		-- FPS Limiter working --
		local cur_time = love.timer.getTime()
		if next_time <= cur_time then
			next_time = cur_time
			return
		end
		love.timer.sleep(next_time - cur_time)
		----------------------------

		if self.camera then
			self.camera:draw(function(l, t, w, h)
				-- if rooms.current.Draw ~= nil then
				-- 	rooms.current:Draw()
				-- end
			end)
		end

		if self.settings.debug then
			-- debug drawings
		end
	end

	function l2df:resize(w, h)
		self.settings.global.width = w
		self.settings.global.height = h

		self.scalex = w / self.settings.gameWidth
		self.scaley = h / self.settings.gameHeight
	end

return l2df