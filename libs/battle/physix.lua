local physix = {}

	function physix:addMotion_X(n)
		self.vel_x = self.vel_x + n
	end
	function physix:addMotion_Y(n)
		self.vel_y = self.vel_y + n
	end
	function physix:addMotion_Z(n)
		self.vel_z = self.vel_z + n
	end


	function physix:setMotion_X(n)
		self.vel_x = n
	end
	function physix:setMotion_Y(n)
		self.vel_y = n
	end
	function physix:setMotion_Z(n)
		self.vel_z = n
	end



	function physix:applyMotions()
		
		if not self.fixed_x then
			self.x = self.x + self.vel_x
		else
			self.fixed_x = false
		end
		
		self.y = self.y + self.vel_y
		self.z = self.z + self.vel_z

		if self.head.type == "character" then
			if self.x <= 0 then self.x = 0
			elseif self.x >= battle.map.head.width then
				self.x = battle.map.head.width
			end
		else
			if self.x <= -300 then self.destroy = true
			elseif self.x >= battle.map.head.width + 300 then
				self.destroy = true
			end
		end

		self.grounded = false
		if self.y <= 0 then
			self.y = 0
			self.grounded = true
		elseif self.y >= battle.map.head.height then
			self.y = battle.map.head.height
		end

		if self.head.type == "character" then
			if self.z <= 0 then self.z = 0
			elseif self.z >= battle.map.head.area then
				self.z = battle.map.head.area
			end
		else
			if self.z <= 0 - battle.map.head.objects_stock then self.z = 0 - battle.map.head.objects_stock
			elseif self.z >= battle.map.head.area + battle.map.head.objects_stock then
				self.z = battle.map.head.area + battle.map.head.objects_stock
			end
		end

	end

	function physix:applyGravity()
		if not self.noGravity then
			if self.head.gravity then
				if self.grounded then
					self.vel_x = self.vel_x * battle.map.head.friction
					self.vel_z = self.vel_z * battle.map.head.friction
					self.vel_y = 0
				else
					self.vel_x = self.vel_x * 0.99
					self.vel_z = self.vel_z * 0.99
					self.vel_y = self.vel_y - battle.map.head.gravity
				end
			else
				self.vel_x = self.vel_x * 0.99
				self.vel_y = self.vel_y * 0.99
				self.vel_z = self.vel_z * 0.99
			end
		else
			self.noGravity = false
		end
	end
return physix