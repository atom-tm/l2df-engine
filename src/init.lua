--- L2DF engine.
-- @module l2df
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

l2df = require((...) .. '.core')

local function dummy() end

local love = _G.love or { ismock = true }
local math = _G.math
local floor = math.floor

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
	-- @param[opt] table kwargs
	-- @param[opt=60] number kwargs.fps
	-- @param[opt=30] number kwargs.datafps
	-- @param[opt=30] number kwargs.speed
	function core:init(kwargs)
		kwargs = kwargs or { }
		-- First call to core.root() always should be in core.init
		Factory:scan(core.root() .. 'class/entity')
		self.fps = kwargs.fps or 60
		self.tickrate = 1 / self.fps
		self.factor = self.fps / (kwargs.datafps or 30)
		self.speed = kwargs.speed or 1

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
		EventManager:subscribe('mousepressed', InputManager.mousepressed, love, InputManager)
		EventManager:subscribe('mousereleased', InputManager.mousereleased, love, InputManager)
		EventManager:subscribe('touchmoved', InputManager.touchmoved, love, InputManager)
		EventManager:subscribe('touchpressed', InputManager.touchpressed, love, InputManager)
		EventManager:subscribe('touchreleased', InputManager.touchreleased, love, InputManager)
		EventManager:subscribe('rawupdate', EventManager.update, love, EventManager)
		EventManager:subscribe('beforepreupdate', SyncManager.persist, EventManager, SyncManager)
		EventManager:subscribe('beforepreupdate', RenderManager.clear, EventManager, RenderManager)
		EventManager:subscribe('beforepreupdate', InputManager.update, EventManager, InputManager)
		EventManager:subscribe('update', PhysixManager.collide, EventManager, PhysixManager)
		EventManager:subscribe('update', SoundManager.update, EventManager, SoundManager)
		EventManager:subscribe('update', ResourceManager.update, EventManager, ResourceManager)
		EventManager:subscribe('postupdate', PhysixManager.update, EventManager, PhysixManager)
		EventManager:subscribe('postupdate', InputManager.advance, EventManager, InputManager)
		EventManager:subscribe('postupdate', SyncManager.commit, EventManager, SyncManager)
		EventManager:subscribe('postupdate', Recorder.update, EventManager, Recorder)
		EventManager:subscribe('draw', RenderManager.render, love, RenderManager)
	end

	--- Tweak simulation speed.
	-- @param number value  
	function core:speedup(value)
		self.speed = value >= 0 and floor(value) or (1 / floor(-value))
	end

	--- Convert
	-- @param number value
	function core:convert(value)
		return floor(value * self.factor)
	end

	--- Engine's game loop.
	-- @return function
	function core.gameloop()
		math.randomseed(core.api.time.now())
		local load = core.load or love.load
		local quit = core.quit or love.quit
		if load then
			load(love.ismock and arg or love.arg.parseGameArguments(arg), arg)
		end
		love.update = love.update or dummy
		love.draw = love.draw or dummy
		local tickrate = core.tickrate
		local fps = 1 / tickrate
		local accumulate = 0
		local throttle = 0
		local delta = 0
		local diff = 0
		local draw = false
		local min = math.min
		local sleep = core.api.time.sleep
		local epump = core.api.event.pump
		local epoll = core.api.event.poll
		local gactive = core.api.render.active
		local gorigin = core.api.render.origin
		local gclear = core.api.render.clear
		local gpresent = core.api.render.present
		local gbackground = core.api.render.backgroundColor
		local getDelta = core.api.time.delta; getDelta()
		return function()
			-- Events
			epump()
			for name, a, b, c, d, e, f in epoll() do
				if name == "quit" then
					if not quit or not quit() then
						return a or 0
					end
				end
				love.handlers[name](a, b, c, d, e, f)
			end

			-- Delta calculations
			tickrate = core.tickrate
			delta = getDelta()

			-- Network and rollbacks
			NetworkManager:update(delta)
			diff, throttle = SyncManager:sync(InputManager.frame)

			-- Update
			draw = false
			accumulate = min(accumulate + delta * core.speed + diff - throttle, fps)
			while accumulate >= tickrate do
				accumulate = accumulate - tickrate
				draw = accumulate < tickrate
				love.update(tickrate, draw)
			end

			-- Draw
			if (draw or not RenderManager.vsync) and gactive() then
				gorigin()
				gclear(gbackground())
				love.draw()
				gpresent()
			end

			-- Throttle = tickrate - accumulate
			sleep(0.001)
		end
	end

return core