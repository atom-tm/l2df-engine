--- L2DF engine
-- @module l2df
-- @author Abelidze, Kasai
-- @copyright Atom-TM 2019

local __DIR__ = (...) .. '.'
gamera		= require(__DIR__ .. 'external.gamera')
json 		= require(__DIR__ .. 'external.json')
---------------------------------------------
l2df = require(__DIR__ .. 'core')
helper = l2df.import 'helper'

local love = _G.love

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

	love.graphics.setDefaultFilter("nearest", "nearest")
	love.keyboard.setKeyRepeat(true)

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
		StatesManager:load('data/states')

		SceneManager:set('sex')
		SceneManager:push('myroom')
		self.tickrate = 1 / 60
	end

	function core:gameloop()
		if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
		if love.timer then love.timer.step() end

		local accumulate = 0
		return function()
			-- Events
			if love.event then
				love.event.pump()
				for name, a,b,c,d,e,f in love.event.poll() do
					if name == "quit" then
						if not love.quit or not love.quit() then
							return a or 0
						end
					end
					love.handlers[name](a,b,c,d,e,f)
				end
			end

			-- Update
			accumulate = accumulate + (love.timer and love.timer.step() or self.tickrate)
			if love.update then
				while accumulate >= self.tickrate do
					love.update(self.tickrate)
					accumulate = accumulate - self.tickrate
				end
			else
				accumulate = accumulate % self.tickrate
			end

			-- Draw
			if love.graphics and love.graphics.isActive() then
				love.graphics.origin()
				love.graphics.clear(love.graphics.getBackgroundColor())

				if love.draw then love.draw() end

				love.graphics.present()
			end

			if love.timer then love.timer.sleep(0.001) end
			-- if love.timer then love.timer.sleep(self.tickrate - accumulate) end
		end
	end

	-- function core:localechanged()
	-- 	self.settings.global.lang = self.i18n.current
	-- end

return core