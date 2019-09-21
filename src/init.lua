local __DIR__ = (...) .. '.'
gamera		= require(__DIR__ .. 'external.gamera')
json 		= require(__DIR__ .. 'external.json')
helper 		= require(__DIR__ .. 'helper')
---------------------------------------------
l2df = require(__DIR__ .. 'core')
local core = l2df

	local EntityManager = core.import 'core.manager.entity'
	local EventManager = core.import 'core.manager.event'
	local ResourseManager = core.import 'core.manager.resourse'
	local GroupManager = core.import 'core.manager.group'
	local SettingsManager = core.import 'core.manager.settings'
	local RenderManager = core.import 'core.manager.render'

	local Entity = core.import "core.class.entity"
	local Room = core.import "core.class.entity.room"

	function core:init()
		EventManager:monitoring(love, love.handlers)
		RenderManager:init()
	end


	--[[local min_dt, next_time

	core.settings	= core.import 'settings'

	core.scalex = 1
	core.scaley = 1

	function core:init(filepath)
		local _ = filepath and self.settings:load(filepath)
		self.sound:setConfig(self.settings.global)

		-- FPS Limiter initialize --
		min_dt = 1 / self.settings.graphic.fpsLimit
		next_time = love.timer.getTime()

		-- I've moved it above, but it can be bad, needs testing
		self.input:init()
		self.rooms:init()

		helper.hook(self.i18n, 'setLocale', self.localechanged, self)
		helper.hook(love, 'update', self.update, self)
		helper.hook(love, 'draw', self.draw, self)
		helper.hook(love, 'resize', self.resize, self)
	end

	function core:update()
		-- Mouse position calculation --
		-- local x, y = love.mouse.getPosition( )
		-- settings.mouseX = x * (settings.gameWidth / settings.global.width)
		-- settings.mouseY = y * (settings.gameHeight / settings.global.height)

		-- FPS Limiter --
		next_time = next_time + min_dt
	end

	function core:localechanged()
		self.settings.global.lang = self.i18n.current
	end

	function core:draw()
		if self.canvas then
			-- love.graphics.draw(self.canvas, 0, 0, 0, self.scalex, self.scaley)
		end

		-- FPS Limiter working --
		local cur_time = love.timer.getTime()
		if next_time <= cur_time then
			next_time = cur_time
			return
		end
		love.timer.sleep(next_time - cur_time)

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

	function core:resize(w, h)
		self.settings.global.width = w
		self.settings.global.height = h

		self.scalex = w / self.settings.gameWidth
		self.scaley = h / self.settings.gameHeight
	end]]

return core