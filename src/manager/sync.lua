--- Synchronization manager.
-- @classmod l2df.manager.sync
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'SyncManager works only with l2df v1.0 and higher')

local log = core.import 'class.logger'
local helper = core.import 'helper'

local type = _G.type
local select = _G.select
local unpack = table.unpack or _G.unpack
local concat = table.concat
local min = math.min
local max = math.max
local abs = math.abs
local floor = math.floor
local crc32 = helper.crc32

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

local SYNC_NONE = 0
local SYNC_ROLLBACK = 1
local SYNC_LOCKSTEP = 2
local SYNC_COUNT = 3

local maxsize = 10
local tickrate = core.tickrate or 1
local min_advantage = tickrate
local max_advantage = tickrate
local last_throttle = 0
local advantage = 0
local firstframe = 0
local snapshots = nil
local callbacks = { }
local checkpoint = { }
local data = { }
local history = { }
local sync_mode = SYNC_ROLLBACK

local Manager = {
	frame = 0, time = 0, size = 1, resync = false, desync = false,
	NONE = SYNC_NONE,
	ROLLBACK = SYNC_ROLLBACK,
	LOCKSTEP = SYNC_LOCKSTEP	
}

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
	-- @param[opt=0] number zero  Initial @{Manager.frame|SyncManager.frame}.
	-- @return l2df.manager.sync
	function Manager:reset(zero)
		zero = zero or 0
		tickrate = core.tickrate or tickrate
		min_advantage = tickrate
		max_advantage = 0.1 * maxsize * tickrate
		last_throttle = 0
		advantage = 0
		callbacks = { }
		checkpoint = { }
		snapshots = nil
		firstframe = zero
		self.resync = false
		self.desync = false
		self.time = zero * tickrate
		self.frame = zero
		self.size = 0
		data = { }
		for i = 1, maxsize do
			data[i] = { }
		end
		history = data[1]
		return self
	end

	--- Updates synchronization mode. 
	-- @param number mode  One of: `NONE`, `ROLLBACK` and `LOCKSTEP` (not implemented).
	-- @return l2df.manager.sync
	function Manager:mode(mode)
		sync_mode = assert(mode >= 0 and mode < SYNC_COUNT and mode, 'Invalid sync mode value')
		return self
	end

	---
	-- @return boolean
	function Manager:is(mode)
		return sync_mode == mode
	end

	---
	-- @return number
	function Manager:syncframe()
		return checkpoint.frame or 0
	end

	--- Updates local simulation advantage value (difference in time between simulations).
	-- @param number timestamp  Time of another simulation.
	function Manager:updateAdvantage(timestamp)
		advantage = max(advantage, self.time - timestamp)
	end

	--- Synchronize frame-counters between simulations.
	-- @param number dt
	-- @param number frame  Target frame for rollback.
	-- @return number delta-time
	-- @return number throttle
	function Manager:sync(dt, frame)
		if self.desync then
			if self.resync == 1 then
				self.resync = true
				return tickrate, dt
			elseif type(self.resync) == 'number' then
				self.size = 0
				self:restore(checkpoint)
				firstframe = self.frame
				last_throttle = 0
				advantage = 0
				snapshots = nil
				local diff = (self.resync - self.frame) * tickrate
				self.resync = false
				return diff, dt
			end
			return 0, dt
		end
		local throttle = advantage >= min_advantage and self.frame - last_throttle > (maxsize -  self.size) * 2 and
			min(advantage, max_advantage) or 0
		if throttle > 0 then
			advantage = advantage - throttle
			last_throttle = self.frame
			log:warn('THROTTLE[%05d] %ds', last_throttle, throttle)
		end
		if sync_mode == SYNC_ROLLBACK and frame < self.frame then
			local diff = self:rollback(frame)
			if diff > 0 then
				log:debug('ROLLBACK[%05d] Size: [%s/%s][%.3f] Advantage: [%.0f][%.3f] Throttle: %.3f',
					self.frame, diff, self.size, diff * tickrate, advantage / tickrate, advantage, throttle
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
			history.hash = nil
			for i = #history, 1, -1 do
				history[i] = nil
			end
			local crc = Manager:hash()
			for i = 1, #callbacks do
				crc(callbacks[i](...))
			end
			history.hash = crc()
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
	function Manager:commit()
		if self.size < maxsize then
			self.size = self.size + 1
		end
		if self.frame == firstframe then
			for i = 1, #history do
				checkpoint[i] = history[i]
			end
			checkpoint.frame = firstframe
			checkpoint.hash = history.hash or 0
			log:info('Initial checkpoint created [%05d][%08X]', firstframe, checkpoint.hash)
		end
		local it = snapshots
		while it do
			if it.frame == self.frame then
				local snapshot = { }
				for i = 1, #history do
					snapshot[i] = history[i]
				end
				snapshot.frame = self.frame
				snapshot.hash = history.hash
				it.callback(snapshot)
			elseif it.frame <= self:syncframe() then
				if it.next then
					it.next.prev = it.prev
				end
				if it.prev then
					it.prev.next = it.next
				end
				if snapshots == it then
					snapshots = it.prev
				end
			end
			it = it.prev
		end
		self.time = self.time + tickrate
		self.frame = self.frame + 1
		history = data[self.frame % maxsize + 1]
		return self
	end

	---
	function Manager:setcheckpoint(snapshot)
		checkpoint = snapshot
	end

	---
	-- @return table
	function Manager:snapshot(frame, callback)
		snapshots = {
			frame = frame,
			callback = callback,
			prev = snapshots
		}
		if snapshots.prev then
			snapshots.prev.next = snapshots
		end
		return snapshots
	end

	---
	-- @return function
	function Manager:hash()
		local checksum = 0
		local hasher = function (...)
			if select('#', ...) == 0 then
				return checksum
			end
			checksum = crc32(concat{...}, checksum)
			return hasher
		end
		return hasher
	end

	--- Restore from snapshot.
	-- @param table snapshot
	function Manager:restore(snapshot)
		if snapshot.frame then
			self.frame = snapshot.frame
			self.time = self.frame * tickrate
		end
		for i = 1, #snapshot do
			snapshot[i][1](unpack(snapshot[i][2]))
			snapshot[i] = nil
		end
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
			self.time = self.frame * tickrate --self.time - size * tickrate
			self.size = self.size - size
			history = data[self.frame % maxsize + 1]
			self:restore(history)
		end
		return size
	end

return setmetatable(Manager, { __call = Manager.init })