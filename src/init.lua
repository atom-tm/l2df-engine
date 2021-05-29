--- L2DF engine.
-- @module l2df
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

l2df = require((...) .. '.core')

local love = _G.love
local math = _G.math

local core = l2df

	local log = core.import 'class.logger'
	local Entity = core.import 'class.entity'
	local Factory = core.import 'manager.factory'
	local EventManager = core.import 'manager.event'
	local GroupManager = core.import 'manager.group'
	local RenderManager = core.import 'manager.render'
	local SoundManager = core.import 'manager.sound'
	local ResourceManager = core.import 'manager.resource'
	local SyncManager = core.import 'manager.sync'
	local InputManager = core.import 'manager.input'
	local NetworkManager = core.import 'manager.network'
	local PhysixManager = core.import 'manager.physix'
	local Recorder = core.import 'manager.recorder'

	--- Engine's standart entry point.
	-- @param number fps
	function core:init(fps)
		-- First call to core.root() always should be in core.init
		Factory:scan(core.root() .. 'class/entity')
		self.tickrate = 1 / (fps or 60)

		EventManager:monitoring(love, love.handlers)
		EventManager:monitoring(love, 'update', 'rawupdate')
		EventManager:monitoring(love, 'draw')
		EventManager:monitoring(Entity, 'new', 'entitycreated', true)
		EventManager:monitoring(NetworkManager, 'update', 'netupdate')

		EventManager:subscribe('entitycreated', EventManager.classInit, Entity, EventManager)
		EventManager:subscribe('entitycreated', GroupManager.classInit, Entity, GroupManager)
		EventManager:subscribe('resize', RenderManager.resize, love, RenderManager)
		EventManager:subscribe('keypressed', InputManager.keypressed, love, InputManager)
		EventManager:subscribe('keyreleased', InputManager.keyreleased, love, InputManager)
		EventManager:subscribe('rawupdate', EventManager.update, love, EventManager)
		EventManager:subscribe('beforepreupdate', SyncManager.persist, EventManager, SyncManager)
		EventManager:subscribe('beforepreupdate', InputManager.update, EventManager, InputManager)
		EventManager:subscribe('beforepreupdate', RenderManager.clear, EventManager, RenderManager)
		EventManager:subscribe('update', SoundManager.update, EventManager, SoundManager)
		EventManager:subscribe('update', PhysixManager.update, EventManager, PhysixManager)
		EventManager:subscribe('update', ResourceManager.update, EventManager, ResourceManager)
		EventManager:subscribe('postupdate', InputManager.advance, EventManager, InputManager)
		EventManager:subscribe('postupdate', SyncManager.commit, EventManager, SyncManager)
		EventManager:subscribe('postupdate', Recorder.update, EventManager, Recorder)
		EventManager:subscribe('draw', RenderManager.render, love, RenderManager)
	end

	--- Engine's game loop.
	-- @return function
	function core.gameloop()
		if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
		if love.timer then
			math.randomseed(love.timer.getTime())
			love.timer.step()
		end

		local tickrate = core.tickrate
		local fps = 1 / tickrate
		local accumulate = 0
		local throttle = 0
		local delta = 0
		local diff = 0
		local draw = false
		local min = math.min
		return function()
			-- Events
			if love.event then
				love.event.pump()
				for name, a, b, c, d, e, f in love.event.poll() do
					if name == "quit" then
						if not love.quit or not love.quit() then
							return a or 0
						end
					end
					love.handlers[name](a, b, c, d, e, f)
				end
			end

			-- Network and rollbacks
			tickrate = core.tickrate
			delta = (love.timer and love.timer.step() or tickrate)
			NetworkManager:update(delta)
			diff, throttle = SyncManager:sync(InputManager.frame)
			if SyncManager.desync then
				SyncManager.desync = false
				love.window.showMessageBox("Alert", "Rollback Desync Detected", "warning", true)
				if love.timer then love.timer.step() end
			end

			-- Update
			accumulate = min(accumulate + delta + diff - throttle, fps)
			if love.update then
				draw = false
				while accumulate >= tickrate do
					accumulate = accumulate - tickrate
					draw = accumulate < tickrate
					love.update(tickrate, draw)
				end
			else
				draw = true
				accumulate = accumulate % tickrate
			end

			-- Draw
			if (draw or not RenderManager.vsync) and love.graphics and love.graphics.isActive() then
				love.graphics.origin()
				love.graphics.clear(love.graphics.getBackgroundColor())
				if love.draw then love.draw() end
				love.graphics.present()
			end

			-- Throttle = tickrate - accumulate
			if love.timer then love.timer.sleep(0.001) end
		end
	end

return core