--- Synchronization manager.
-- @classmod l2df.manager.sync
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'SyncManager works only with l2df v1.0 and higher')

local log = core.import 'class.logger'
local helper = core.import 'helper'
local EventManager = core.import 'manager.event'
local Input = core.import 'manager.input'

local type = _G.type
local pairs = _G.pairs
local select = _G.select
local tostring = _G.tostring
local unpack = table.unpack or _G.unpack
local concat = table.concat
local sort = table.sort
local min = math.min
local max = math.max
local abs = math.abs
local floor = math.floor
local crc32 = helper.crc32

local Manager

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
local test = nil
local test_subscription = nil
local HASH_FAST = 'fast'
local HASH_FULL = 'full'
local DEFAULT_TEST_ROLLBACKS = {
	{ frame = 34, target = 6 },
	{ frame = 96, target = 54 },
	{ frame = 156, target = 112 },
	{ frame = 216, target = 170 },
}

local function valueKey(value)
	local kind = type(value)
	if kind == 'number' then
		return 'n:' .. tostring(value)
	elseif kind == 'string' then
		return 's:' .. value
	elseif kind == 'boolean' then
		return value and 'b:1' or 'b:0'
	end
	return kind .. ':'
end

local function hashValue(hash, value, seen)
	local kind = type(value)
	if kind == 'nil' then
		hash('nil;')
	elseif kind == 'number' or kind == 'string' or kind == 'boolean' then
		hash(kind, ':', tostring(value), ';')
	elseif kind == 'table' then
		if value.___class then
			local vdata = type(value.data) == 'table' and value.data or nil
			hash('ref:', vdata and (vdata.syncid or vdata.index or vdata.player) or value.name or 'class', ';')
			return
		end
		if seen[value] then
			hash('cycle;')
			return
		end
		seen[value] = true
		local keys = { }
		for key, val in pairs(value) do
			if type(val) ~= 'function'
			and type(val) ~= 'userdata'
			and type(val) ~= 'thread'
			and type(key) ~= 'table'
			and tostring(key):sub(1, 3) ~= '___'
			then
				keys[#keys + 1] = key
			end
		end
		sort(keys, function (a, b) return valueKey(a) < valueKey(b) end)
		hash('{')
		for i = 1, #keys do
			local key = keys[i]
			hashValue(hash, key, seen)
			hashValue(hash, value[key], seen)
		end
		hash('}')
		seen[value] = nil
	end
end

local function hashField(value)
	local hash = Manager:hash()
	hashValue(hash, value, { })
	return hash()
end

local function debugValue(value)
	local kind = type(value)
	if kind == 'table' then
		return ('table:%08X'):format(hashField(value))
	end
	return kind .. ':' .. tostring(value)
end

local function dataDebug(objdata)
	local fields = { }
	for key, value in pairs(objdata or { }) do
		if type(value) ~= 'function'
		and type(value) ~= 'userdata'
		and type(value) ~= 'thread'
		and type(key) ~= 'table'
		and tostring(key):sub(1, 3) ~= '___'
		then
			fields[valueKey(key)] = {
				key = key,
				hash = hashField(value),
				value = debugValue(value),
			}
		end
	end
	return fields
end

local function logFieldMismatch(frame, object, oldFields, newFields)
	local keys = { }
	for key in pairs(oldFields or { }) do
		keys[#keys + 1] = key
	end
	for key in pairs(newFields or { }) do
		if not oldFields or not oldFields[key] then
			keys[#keys + 1] = key
		end
	end
	sort(keys)
	for i = 1, #keys do
		local old = oldFields and oldFields[keys[i]]
		local new = newFields and newFields[keys[i]]
		local oldHash = old and old.hash or nil
		local newHash = new and new.hash or nil
		if oldHash ~= newHash then
			log:error('TEST data field mismatch at frame %05d object %d key %s: %08X != %08X',
				frame, object, tostring((old or new).key), oldHash or 0, newHash or 0
			)
			log:error('TEST data old: %s', old and old.value or 'nil')
			log:error('TEST data new: %s', new and new.value or 'nil')
			break
		end
	end
end

local function objectDetails(index, obj)
	local objdata = obj.data or { }
	local result = { components = { } }
	local hash = Manager:hash()
	hash('data:')
	hashValue(hash, objdata, { })
	result.data = hash()
	result.fields = test and test.debug and dataDebug(objdata) or nil
	local objectHash = Manager:hash()
	objectHash('obj:', index, ':', objdata.syncid or objdata.index or objdata.player or obj.key or index, ':', obj.active and 1 or 0, ';')
	objectHash('data:', result.data, ';')
	if obj.components then
		for id, component in obj.components:enum(true) do
			hash = Manager:hash()
			hash('component:', id, ';')
			hashValue(hash, obj.cdata and obj.cdata[component], { })
			local componentHash = hash()
			result.components[id] = {
				hash = componentHash,
			}
			objectHash('component:', id, ':', componentHash, ';')
		end
	end
	result.hash = objectHash()
	return result
end

local function fullObjectHash(hash, index, obj)
	local details = objectDetails(index, obj)
	hash('objhash:', index, ':', details.hash, ';')
	return details
end

local function observeTestHash(frame, hash, details)
	if not test then return end
	local previous = test.hashes[frame]
	if previous and previous ~= hash then
		test.failures[#test.failures + 1] = { frame = frame, expected = previous, actual = hash }
		log:error('TEST mismatch at frame %05d: %08X != %08X', frame, previous, hash)
		local previousDetails = test.details[frame] or { }
		for i = 1, max(#previousDetails, #(details or { })) do
			local old = previousDetails[i]
			local new = details and details[i]
			if old and new and old.hash ~= new.hash then
				log:error('TEST object mismatch at frame %05d object %d: %08X != %08X', frame, i, old.hash or 0, new.hash or 0)
				if old.data ~= new.data then
					log:error('TEST data mismatch at frame %05d object %d: %08X != %08X', frame, i, old.data or 0, new.data or 0)
					if old.fields or new.fields then
						logFieldMismatch(frame, i, old.fields, new.fields)
					end
				else
					local oldComponents = old.components or { }
					local newComponents = new.components or { }
					for id = 1, max(#oldComponents, #newComponents) do
						local oldComponent = oldComponents[id]
						local newComponent = newComponents[id]
						local oldHash = type(oldComponent) == 'table' and oldComponent.hash or oldComponent
						local newHash = type(newComponent) == 'table' and newComponent.hash or newComponent
						if oldHash ~= newHash then
							log:error('TEST component mismatch at frame %05d object %d component %d: %08X != %08X',
								frame, i, id, oldHash or 0, newHash or 0
							)
							break
						end
					end
				end
				break
			elseif (old and old.hash or nil) ~= (new and new.hash or nil) then
				log:error('TEST object mismatch at frame %05d object %d: %08X != %08X', frame, i, old and old.hash or 0, new and new.hash or 0)
				break
			end
		end
	elseif not previous then
		test.hashes[frame] = hash
		test.details[frame] = details
	end
end

local function filterRollbacks(frames, rollbacks)
	local filtered = { }
	if rollbacks == false then
		return filtered
	end
	rollbacks = rollbacks or DEFAULT_TEST_ROLLBACKS
	for i = 1, #rollbacks do
		local rollback = rollbacks[i]
		if rollback.frame and rollback.target and rollback.frame <= frames then
			filtered[#filtered + 1] = {
				frame = rollback.frame,
				target = rollback.target,
			}
		end
	end
	sort(filtered, function (a, b) return a.frame < b.frame end)
	return filtered
end

local function defaultTestInput()
	return 0
end

local function testHashMode(mode, debug)
	if mode == nil then
		return debug and HASH_FULL or HASH_FAST
	end
	assert(mode == HASH_FAST or mode == HASH_FULL, 'Invalid sync test hash mode')
	return mode
end

local function stopTest()
	if test_subscription then
		EventManager:unsubscribeById('postupdate', test_subscription)
		test_subscription = nil
	end
	test = nil
end

local function rollbackTestMode()
	if not (test and test.rollbacks) then return end
	for i = 1, #test.rollbacks do
		local rollback = test.rollbacks[i]
		if not rollback.done and Manager.frame >= rollback.frame then
			rollback.done = true
			Input.frame = rollback.target
			local diff = Manager:rollback(rollback.target)
			log:warn('TEST rollback probe: %05d -> %05d [%d]', Manager.frame + diff, rollback.target, diff)
			break
		end
	end
end

Manager = {
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
		stopTest()
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

	--- Start or stop deterministic synchronization test mode.
	-- @param[opt] table|false config  Test configuration, or `false` to stop an active test.
	-- @param[opt=240] number config.frames  Frame count to verify.
	-- @param[opt=2] number config.players  Count of players to seed with scripted input.
	-- @param[opt] function config.input  Callback returning input data for `(player, frame)`.
	-- @param[opt] table config.rollbacks  Rollback probes, filtered by `config.frames`.
	-- @param[opt=false] boolean config.debug  Store detailed per-field diagnostics.
	-- @param[opt='fast'] string config.hash  Hash mode: `fast` or `full`.
	-- @param[opt] function config.fasthash  Fast object hash callback for `(hash, index, obj)`.
	-- @param[opt] function config.onfinish  Callback receiving `(success, failures)`.
	-- @return l2df.manager.sync
	function Manager:test(config)
		if config == false then
			stopTest()
			return self
		end
		stopTest()
		config = config or { }
		local debug = not not config.debug
		test = {
			frames = config.frames or 240,
			players = config.players or 2,
			input = config.input or defaultTestInput,
			debug = debug,
			hash = testHashMode(config.hash, debug),
			fasthash = config.fasthash,
			onfinish = config.onfinish,
			hashes = { },
			details = { },
			failures = { },
		}
		test.rollbacks = filterRollbacks(test.frames, config.rollbacks)
		for frame = 0, test.frames do
			for player = 1, test.players do
				Input:addinput(test.input(player, frame) or 0, player, frame)
			end
		end
		test_subscription = EventManager:subscribe('postupdate', rollbackTestMode, EventManager)
		log:info('TEST started: %d frames, %d rollback probes, hash=%s', test.frames, #test.rollbacks, test.hash)
		return self
	end

	--- Hash an object for active sync test diagnostics.
	-- @param function hash
	-- @param number index
	-- @param table obj
	-- @return boolean  `true` when test mode is active, `false` otherwise.
	function Manager:testobject(hash, index, obj)
		if not test then
			return false
		end
		if test.hash == HASH_FAST then
			if test.fasthash then
				test.fasthash(hash, index, obj)
				return true
			end
			return false
		end
		test.current_details = test.current_details or { }
		test.current_details[index] = fullObjectHash(hash, index, obj)
		return true
	end

	--- Finalize the current test frame hash and compare it with previous visits.
	-- @param function hash
	-- @return number
	function Manager:testhash(hash)
		local value = hash()
		if test then
			observeTestHash(self.frame, value, test.current_details)
			test.current_details = nil
		end
		return value
	end

	--- Update test mode finish handling.
	-- @return boolean  `true` while test mode owns the frame.
	function Manager:testupdate()
		if not test then
			return false
		end
		if self.frame >= test.frames then
			local state = test
			local failures = state.failures
			local success = #failures == 0
			stopTest()
			if state.onfinish then
				state.onfinish(success, failures)
			elseif success then
				log:success('TEST passed: %d frames verified', state.frames)
			else
				log:error('TEST failed: %d mismatches', #failures)
			end
		end
		return true
	end

	--- Restore from snapshot.
	-- @param table snapshot
	function Manager:restore(snapshot)
		if not snapshot then return end
		if snapshot.frame then
			self.frame = snapshot.frame
			self.time = self.frame * tickrate
		end
		for i = 1, #snapshot do
			snapshot[i][1](unpack(snapshot[i][2]))
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
