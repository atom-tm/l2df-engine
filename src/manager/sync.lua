--- Synchronization manager.
-- @classmod l2df.manager.sync
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'SyncManager works only with l2df v1.0 and higher')

local log = core.import 'class.logger'
local helper = core.import 'helper'

local type = _G.type
local unpack = table.unpack or _G.unpack
local min = math.min
local max = math.max
local abs = math.abs
local floor = math.floor

local function createNode()
	local node = { }
	node.next = node
	node.prev = node
	node.time = 1e10
	return node
end

local function destroyNode(node)
	for i = #node, 1, -1 do
		node[i] = nil
	end
	if node.next ~= node then
		node.next.prev = node.prev
		node.prev.next = node.next
	end
	node.next = nil
	node.prev = nil
end

local maxsize = 10
local tickrate = core.tickrate or 1
local min_advantage = tickrate
local max_advantage = tickrate * (0.1 / tickrate)
local last_throttle = 0
local advantage = 0
local callbacks = { }
local data = { }
local history = { }

local Manager = { time = 0, size = 1, desync = false }

	--- Internal frame counter. Advances on each @{Manager:commit|SyncManager:commit()} call.
	-- @field number Manager.frame

	--- Time passed since start of the synchronization context.
	-- @field number Manager.time

	--- Size of the rollback window. It is the maximum count of taken snapshots.
	-- @field number Manager.size

	--- Value identifying that there was found a desync.
	-- @field boolean Manager.desync

	--- Configure @{l2df.manager.sync|SyncManager}.
	-- @param[opr] table kwargs  Keyword arguments.
	-- @param[opt=10] number kwargs.size  Maximum count of taken snapshots used for rollback.
	-- @param[opt=0] number kwargs.zero  Initial @{Manager.time|SyncManager.time}.
	-- @return l2df.manager.sync
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		maxsize = max(1, kwargs.size or maxsize)
		self:reset()
		return self
	end

	--- Reset manager and drop all snapshots.
	-- @param[opt=0] number zero  Initial @{Manager.time|SyncManager.time}.
	function Manager:reset(zero)
		self.desync = false
		self.time = zero or 0
		self.size = 0
		self.frame = 0
		tickrate = core.tickrate or tickrate
		min_advantage = tickrate
		max_advantage = tickrate * (0.1 / tickrate)
		callbacks = { }
		data = { }
		for i = 1, maxsize do
			data[i] = { }
		end
		history = data[1]
	end

	--- Updates local simulation advantage value (difference in time between simulations).
	-- @param number timestamp  Time of another simulation.
	function Manager:updateAdvantage(timestamp)
		advantage = max(advantage, self.time - timestamp)
	end

	--- Synchronize frame-counters between simulations.
	-- @param number frame  Target frame for rollback.
	-- @return number delta-time
	-- @return number throttle
	function Manager:sync(frame)
		local throttle = advantage >= min_advantage and self.frame - last_throttle > (maxsize -  self.size) * 2 and min(advantage, max_advantage) or 0
		if throttle > 0 then
			advantage = advantage - throttle
			last_throttle = self.frame
		end
		if frame < self.frame then
			local diff = self:rollback(frame)
			if diff > 0 then
				log:debug('ROLLBACK Timer: %s Size: [%s/%s][%.3f] Advantage: %.3f Throttle: %.3f',
					self.frame, diff, self.size, diff * tickrate, advantage, throttle
				)
				return diff * tickrate, throttle
			end
		end
		return 0, throttle
	end

	--- Register callback functions for persisting state or call all of them.
	-- All of that functions would be called with next @{Manager.persist|SyncManager:persist(...)} call.
	-- Usually you want to call it before start of each frame simulation.
	-- @param[opt] function callback  State persisting function.
	-- @param[opt] ... ...  Arguments passed to all stored callbacks.
	function Manager.persist(callback, ...)
		if type(callback) == 'function' then
			callbacks[#callbacks + 1] = callback
		else
			for i = #history, 1, -1 do
				history[i] = nil
			end
			for i = 1, #callbacks do
				callbacks[i](...)
			end
		end
	end

	--- Persist a function and its arguments to restore state during rollback.
	-- @param function f  Restore-function which whould be used later to restore the initial state.
	-- @param ... ...  Arguments passed to restore-function during rollback.
	-- @return l2df.manager.sync
	function Manager:stage(f, ...)
		history[#history + 1] = { f, { ... } }
		return self
	end

	--- Commit all staged functions and advance state.
	-- @param number dt  Delta-time since last game tick.
	-- @return l2df.manager.sync
	function Manager:commit(dt)
		if self.size < maxsize then
			self.size = self.size + 1
		end
		self.time = self.time + dt
		self.frame = self.frame + 1
		history = data[self.frame % maxsize + 1]
		return self
	end

	--- Rollback in history and execute persisted functions.
	-- @param number frame  Target frame for rollback.
	-- @return number  Rollback size.
	function Manager:rollback(frame)
		local size = self.frame - frame
		if size < 0 then
			log:warn('Rollback in future [%s] -> [%s]', self.frame, frame)
			size = 0
		end
		-- TODO: if size is greater than last stored snapshot then throw error
		if size > self.size then
			log:warn('Too big rollback [%s] -> [%s] = %s. SyncWindow: %s', self.frame, frame, size, self.size)
			self.desync = true
			size = self.size
		end
		if size > 0 then
			self.frame = self.frame - size
			self.time = self.time - size * tickrate
			self.size = self.size - size
			history = data[self.frame % maxsize + 1]
			for i = 1, #history do
				history[i][1](unpack(history[i][2]))
				history[i] = nil
			end
		end
		return size
	end

return setmetatable(Manager, { __call = Manager.init })