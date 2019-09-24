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
	local StatesManager = core.import 'core.manager.states'

	local Entity = core.import "core.class.entity"
	local Room = core.import "core.class.entity.room"
	local UI = core.import "core.class.entity.ui"
	local Frames = core.import "core.class.component.frames"
	local Text = core.import 'core.class.component.print'

	function core:init()
		love.keyboard.setKeyRepeat(true)
		EventManager:monitoring(love, love.handlers)
		EventManager:monitoring(love, "update", dt)
		EventManager:monitoring(love, "draw")
		RenderManager:init()

		StatesManager:load("data/states")

		local ui
		ui = UI.Animation({{ "sprites/UI/loading.png", 4, 3, 140, 140 }}, 55, 25, {
			{ pic = 1, id = 1, next = 2, wait = 30 },
			{ pic = 2, id = 2, next = 3, wait = 30 },
			{ pic = 3, id = 3, next = 4, wait = 30 },
			{ pic = 4, id = 4, next = 5, wait = 30 },
			{ pic = 5, id = 5, next = 6, wait = 30 },
			{ pic = 6, id = 6, next = 7, wait = 30 },
			{ pic = 7, id = 7, next = 8, wait = 30 },
			{ pic = 8, id = 8, next = 9, wait = 30 },
			{ pic = 9, id = 9, next = 10, wait = 30 },
			{ pic = 10, id = 10, next = 11, wait = 30 },
			{ pic = 11, id = 11, next = 12, wait = 30 },
			{ pic = 12, id = 12, next = 1, wait = 30, states = {{ 229, { speed = 0.1 }}} },
		})
		ui:addComponent(Text("Hello world"))
		ui.vars.persistentStates[1] = { 229, { speed = 0.5 }}


		local f = function (_, key)
		print(key)
			ui.vars.y = key == 'w' and ui.vars.y - 5 or ui.vars.y
			ui.vars.y = key == 's' and ui.vars.y + 5 or ui.vars.y
			ui.vars.x = key == 'a' and ui.vars.x - 5 or ui.vars.x
			ui.vars.x = key == 'd' and ui.vars.x + 5 or ui.vars.x
			ui.vars.pic = key == '=' and ui.vars.pic + 1 or ui.vars.pic
			ui.vars.pic = key == '-' and ui.vars.pic - 1 or ui.vars.pic
			print(ui.vars.pic)
		end

		EventManager:subscribe("keypressed", f)
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