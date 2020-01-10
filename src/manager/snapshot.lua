--- Simulation manager
-- @classmod l2df.core.manager.simulation
-- @author Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'SnapshotManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'
local unpack = table.unpack or _G.unpack

local function createNode()
	local node = { }
	node.next = node
	node.prev = node
	node.time = 0
	return node
end

local function destroyNode(node)
	for i = #node, 1 do
		node[i] = nil
	end
	if node.next ~= node then
		node.next.prev = node.prev
		node.prev.next = node.next
	end
	node.next = nil
	node.prev = nil
end

local history = createNode()

local Manager = { time = 0, size = 1, maxsize = 1 }

	---
	-- @return SnapshotManager
	function Manager:init(maxsize)
		self.maxsize = maxsize
		self.size = 1
		self.time = 0
		history = createNode()
		return self
	end

	---
	function Manager:update(dt)
		self.time = self.time + dt
	end

	---
	-- @param function f
	-- @return SnapshotManager
	function Manager:stage(f, ...)
		history[#history + 1] = { f, { ... } }
		return self
	end

	function Manager:hist()
		return history
	end

	---
	-- @return SnapshotManager
	function Manager:commit()
		local node = createNode()
		node.next = history.next
		node.prev = history
		history.next.prev = node
		history.next = node
		history.time = self.time
		history = node

		if self.size >= self.maxsize then
			destroyNode(history.next)
		else
			self.size = self.size + 1
		end
		return self
	end

	---
	-- @return number
	function Manager:rollback(timestamp)
		-- TODO: if timestamp is more than last stored snapshot then throw error
		history.time = history.time == 0 and self.time or history.time
		local it = history
		repeat
			if it.time < timestamp or it.prev.time > it.time or it == it.prev then
				break
			end
			it = it.prev
			destroyNode(it.next)
			self.size = self.size - 1
		until it == history

		history = it
		for i = 1, #history do
			history[i][1](unpack(history[i][2]))
		end
		local diff = self.time - history.time
		self.time = history.time
		return diff
	end

return Manager