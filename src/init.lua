--- L2DF engine
-- @module l2df
-- @author Abelidze, Kasai
-- @copyright Atom-TM 2019

l2df = require((...) .. '.core')

local love = _G.love
local math = _G.math

local tickrate = 1 / 60

local core = l2df

	local log = core.import 'class.logger'
	local parser = core.import 'class.parser.lffs'

	local EventManager = core.import 'manager.event'
	local GroupManager = core.import 'manager.group'
	local RenderManager = core.import 'manager.render'
	local ResourceManager = core.import 'manager.resource'
	local SnapshotManager = core.import 'manager.snapshot'
	local InputManager = core.import 'manager.input'
	local NetworkManager = core.import 'manager.network'

	local Entity = core.import 'class.entity'

	---
	-- @param number fps
	function core:init(fps)
		-- First call to core.root() always should be in core.init
		parser:scan(core.root() .. 'class/entity')
		tickrate = 1 / (fps or 60)
		love.graphics.setDefaultFilter('nearest', 'nearest')

		if love.timer then math.randomseed(love.timer.getTime()) end

		EventManager:monitoring(love, love.handlers)
		EventManager:monitoring(love, 'update')
		EventManager:monitoring(love, 'draw')
		EventManager:monitoring(Entity, 'new', true)

		EventManager:subscribe('new', EventManager.classInit, Entity, EventManager)
		EventManager:subscribe('new', GroupManager.classInit, Entity, GroupManager)
		EventManager:subscribe('resize', RenderManager.resize, love, RenderManager)
		EventManager:subscribe('draw', RenderManager.draw, love, RenderManager)
		EventManager:subscribe('update', InputManager.update, love, InputManager)
		EventManager:subscribe('update', RenderManager.clear, love, RenderManager) -- this order
		EventManager:subscribe('update', EventManager.update, love, EventManager) -- is important
		EventManager:subscribe('update', ResourceManager.update, love, ResourceManager)
		EventManager:subscribe('update', SnapshotManager.update, love, SnapshotManager)
		EventManager:subscribe('keypressed', InputManager.keypressed, love, InputManager)
		EventManager:subscribe('keyreleased', InputManager.keyreleased, love, InputManager)
	end

	---
	-- @return function
	function core:gameloop()
		if love.load then love.load(love.arg.parseGameArguments(arg), arg) end
		if love.timer then love.timer.step() end

		local accumulate = 0
		local delta = 0
		local time = 0
		local draw = false
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
			delta = love.timer and love.timer.step() or tickrate
			NetworkManager:update(delta)
			if InputManager.time < SnapshotManager.time then
				accumulate = accumulate + SnapshotManager:rollback(InputManager.time)
				time = InputManager.time
				InputManager.time = SnapshotManager.time
				log:debug('ROLLBACK %s -> %s', time, InputManager.time)
			end

			-- Update
			accumulate = accumulate + delta
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
			if draw and love.graphics and love.graphics.isActive() then
				love.graphics.origin()
				love.graphics.clear(love.graphics.getBackgroundColor())

				if love.draw then love.draw() end

				love.graphics.present()
			end

			if love.timer then love.timer.sleep(0.001) end
			-- if love.timer then love.timer.sleep(self.tickrate - accumulate) end
		end
	end

return core