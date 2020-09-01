--- Synchronization manager
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

	--- Init
	-- @param number size
	-- @return l2df.manager.sync
	function Manager:init(size)
		maxsize = max(1, size or maxsize)
		self:reset()
		return self
	end

	--- Reset manager and drop all snapshots
	-- @param[opt] number zero  Default is 0.
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

	---
	-- @param number timestamp  Advantage
	function Manager:updateAdvantage(timestamp)
		advantage = max(advantage, self.time - timestamp)
	end

	---
	-- @param number frame
	-- @return boolean
	-- @return number
	function Manager:sync(frame)
		local throttle = advantage < min_advantage and 0 or (frame - last_throttle > 40) and min(advantage, max_advantage) or 0
		advantage = advantage - throttle
		if frame < self.frame then
			local diff = self:rollback(frame)
			if diff > 0 then
				log:debug('ROLLBACK Timer: %s Size: [%s/%s][%.3f] Advantage: %.3f Throttle: %.3f',
					self.frame, diff, self.size, diff * tickrate, advantage, throttle
				)
				return true, diff * tickrate, throttle
			end
		end
		return false, 0, throttle
	end

	--- Persist state
	-- @param function|table callback
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

	--- Persist a function and its arguments to restore state during rollback
	-- @param function f
	-- @return l2df.manager.sync
	function Manager:stage(f, ...)
		history[#history + 1] = { f, { ... } }
		return self
	end

	--- Commit all staged functions and advance state
	-- @param number dt
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

	--- Rollback in history and execute persisted functions
	-- @param number frame
	-- @return number
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

return Manager