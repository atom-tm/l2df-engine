local physix = {}

	--- Apply motion to current velocity_x
	-- @param x, number  Specified value
	function physix:addMotion_X(x)
		self.vel_x = self.vel_x + x
	end

	--- Apply motion to current velocity_y
	-- @param y, number  Specified value
	function physix:addMotion_Y(y)
		self.vel_y = self.vel_y + y
	end

	--- Apply motion to current velocity_z
	-- @param z, number  Specified value
	function physix:addMotion_Z(z)
		self.vel_z = self.vel_z + z
	end

	--- Set current velocity_x to specified value
	-- @param vx, number  Specified value
	function physix:setMotion_X(vx)
		self.vel_x = vx
	end

	--- Set current velocity_y to specified value
	-- @param vy, number  Specified value
	function physix:setMotion_Y(vy)
		self.vel_y = vy
	end

	--- Set current velocity_z to specified value
	-- @param vz, number  Specified value
	function physix:setMotion_Z(vz)
		self.vel_z = vz
	end

	--- Process motion by applying velocity to current position
	function physix:applyMotions()
		self.x = self.x + self.vel_x
		self.y = self.y + self.vel_y
		self.z = self.z + self.vel_z

		if self.head.type == "character" then
			if self.x <= 0 then
				self.x = 0
			elseif self.x >= battle.map.head.width then
				self.x = battle.map.head.width
			end
		elseif self.x <= -300 or self.x >= battle.map.head.width + 300 then
			self.destroy = true
		end

		self.grounded = false		
		if self.y <= 0 and self.vel_y <= 0 then
			self.y = 0
			self.grounded = true
		elseif self.y >= battle.map.head.height then
			self.y = battle.map.head.height
		end

		if self.head.type == "character" then
			if self.z <= 0 then
				self.z = 0
			elseif self.z >= battle.map.head.area then
				self.z = battle.map.head.area
			end
		else
			if self.z <= 0 - battle.map.head.objects_stock then
				self.z = 0 - battle.map.head.objects_stock
			elseif self.z >= battle.map.head.area + battle.map.head.objects_stock then
				self.z = battle.map.head.area + battle.map.head.objects_stock
			end
		end
	end

	--- Apply gravity to current velocity
	function physix:applyGravity()
		self.old_vel_x = self.vel_x
		self.old_vel_y = self.vel_y
		self.old_vel_z = self.vel_z
		
		if self.gravity then
			if self.grounded then
				if self.x_friction then
					self.vel_x = self.vel_x * battle.map.head.friction
				end
				if self.z_friction then
					self.vel_z = self.vel_z * battle.map.head.friction
				end
				self.vel_y = 0
			else
				if self.x_friction then
					self.vel_x = self.vel_x * 0.99
				end
				if self.z_friction then
					self.vel_z = self.vel_z * 0.99
				end
				self.vel_y = self.vel_y - battle.map.head.gravity
			end
		end
	end

return physix