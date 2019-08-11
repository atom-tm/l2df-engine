local core = l2df or require((...):match("(.-)[^%.]+%.[^%.]+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "PhysixComponent works only with l2df v1.0 and higher")

local Component = core.import "core.entities.component"

local PhysixComponent = Component:extend({
	x = 0, y = 0, z = 0,
	vx = 0, vy = 0, vz = 0,
	grounded = true,
	gravity = true,
	map = { head = { } }
})

	--- Apply motion to current velocity_x
	-- @param x, number  Specified value
	function PhysixComponent:addMotionX(x)
		self.vx = self.vx + x
	end

	--- Apply motion to current velocity_y
	-- @param y, number  Specified value
	function PhysixComponent:addMotionY(y)
		self.vy = self.vy + y
	end

	--- Apply motion to current velocity_z
	-- @param z, number  Specified value
	function PhysixComponent:addMotionZ(z)
		self.vz = self.vz + z
	end

	--- Set current velocity_x to specified value
	-- @param vx, number  Specified value
	function PhysixComponent:setMotionX(vx)
		self.vx = vx
	end

	--- Set current velocity_y to specified value
	-- @param vy, number  Specified value
	function PhysixComponent:setMotionY(vy)
		self.vy = vy
	end

	--- Set current velocity_z to specified value
	-- @param vz, number  Specified value
	function PhysixComponent:setMotionZ(vz)
		self.vz = vz
	end

	--- Process motion by applying velocity to current position
	function PhysixComponent:applyMotions(dt)
		self.x = self.x + self.vx * dt
		self.y = self.y + self.vy * dt
		self.z = self.z + self.vz * dt

		if self.head.type == "character" then
			if self.x <= 0 then
				self.x = 0
			elseif self.x >= self.map.head.width then
				self.x = self.map.head.width
			end
		elseif self.x <= -300 or self.x >= self.map.head.width + 300 then
			self.destroy = true
		end

		self.grounded = false		
		if self.y <= 0 and self.vy <= 0 then
			self.y = 0
			self.grounded = true
		elseif self.y >= self.map.head.height then
			self.y = self.map.head.height
		end

		if self.head.type == "character" then
			if self.z <= 0 then
				self.z = 0
			elseif self.z >= self.map.head.area then
				self.z = self.map.head.area
			end
		else
			if self.z <= 0 - self.map.head.objects_stock then
				self.z = 0 - self.map.head.objects_stock
			elseif self.z >= self.map.head.area + self.map.head.objects_stock then
				self.z = self.map.head.area + self.map.head.objects_stock
			end
		end
	end

	--- Apply gravity to current velocity
	function PhysixComponent:applyGravity(dt)
		self.old_vx = self.vx
		self.old_vy = self.vy
		self.old_vz = self.vz
		
		if not self.gravity then return end

		if self.grounded then
			if self.x_friction then
				self.vx = self.vx * self.map.friction * dt
			end
			if self.z_friction then
				self.vz = self.vz * self.map.friction * dt
			end
			self.vy = 0
		else
			if self.x_friction then
				self.vx = self.vx * 0.99 * dt
			end
			if self.z_friction then
				self.vz = self.vz * 0.99 * dt
			end
			self.vy = self.vy - self.map.head.gravity * dt
		end
	end

return PhysixComponent