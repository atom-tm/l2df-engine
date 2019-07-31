local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "PhysixSystem works only with l2df v1.0 and higher")

local System = core.import "core.entities.system"
local sin = math.sin
local cos = math.cos

local PhysixSystem = System:extend()

	function PhysixSystem:init()
		self.time = 0
	end

	function PhysixSystem:update(dt)
		self.time = self.time + dt
		for _, obj in pairs(self.manager.groups.physical.entities) do
			obj.y = obj.y - 256 * sin(self.time) * dt
			obj.x = obj.x - 256 * cos(self.time) * dt
		end
	end

return PhysixSystem