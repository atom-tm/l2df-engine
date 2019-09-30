local __DIR__ = (...) .. '.'
gamera		= require(__DIR__ .. 'external.gamera')
json 		= require(__DIR__ .. 'external.json')
---------------------------------------------
l2df = require(__DIR__ .. 'core')
helper = l2df.import 'helper'

local core = l2df

	local EntityManager = core.import 'core.manager.entity'
	local EventManager = core.import 'core.manager.event'
	local GroupManager = core.import 'core.manager.group'
	local RenderManager = core.import 'core.manager.render'
	local StatesManager = core.import 'core.manager.states'
	local SceneManager = core.import 'core.manager.scene'

	local Entity = core.import 'core.class.entity'
	local Scene = core.import 'core.class.entity.scene'
	local Print = core.import 'core.class.component.print'
	local UI = core.import 'core.class.entity.ui'

	local parser = core.import 'parsers.lffs'

	function core:init()
		-- First call to core.root() always should be in core.init
		parser:scan(core.root() .. 'core/class/entity')

		RenderManager:init()
		EntityManager:setRoot(SceneManager.root)

		EventManager:monitoring(love, love.handlers)
		EventManager:monitoring(love, 'update')
		EventManager:monitoring(love, 'draw')
		EventManager:monitoring(Entity, 'new', true)
		EventManager:monitoring(Scene, 'new', true)

		EventManager:subscribe('new', EventManager.classInit, Entity, EventManager)
		EventManager:subscribe('new', GroupManager.classInit, Entity, GroupManager)
		EventManager:subscribe('new', SceneManager.classInit, Scene, SceneManager)
		EventManager:subscribe('update', EventManager.update, love, EventManager)

		SceneManager:load('scenes/')

		SceneManager:set('sex')
		SceneManager:push('myroom')

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