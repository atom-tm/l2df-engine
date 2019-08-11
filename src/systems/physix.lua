local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "PhysixSystem works only with l2df v1.0 and higher")

local System = core.import "core.entities.system"

local sin = math.sin
local cos = math.cos

local PhysixSystem = System:extend()

	function PhysixSystem:init()
		self.time = 0
		self.loaded = false
		self.rooms = { }
	end

	function PhysixSystem:roomloaded(room)
		if self.rooms[room] then
			self.time = self.rooms[room].time
		else
			self.time = 0
		end
		self.loaded = true
	end

	function PhysixSystem:roomleaved(room)
		self.loaded = false
		self.rooms[room] = self.rooms[room] or { }
		self.rooms[room].time = self.time
	end

	function PhysixSystem:update(dt)
		if not self.loaded then return end

		self.time = self.time + dt
		for _, obj in pairs(self.groups.physical.entities) do
			obj:applyGravity(dt)
			-- obj:applyMotions(dt)
		end
	end

return PhysixSystem