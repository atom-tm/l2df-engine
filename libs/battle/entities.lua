local entities = {}
	entities.list = {}

	function entities.create(id)
		if resourses.entities[id] == nil then return nil end
		local created_object = func.CopyTable(resourses.entities[id])
		if created_object ~= nil then
			
			created_object.destroy = false
			created_object.first_tick = true

			created_object.gravity = false

			created_object.r = 1
			created_object.g = 1
			created_object.b = 1
			created_object.o = 1

			created_object.x = 0
			created_object.y = 0
			created_object.z = 0

			created_object.vel_x = 0
			created_object.vel_y = 0
			created_object.vel_z = 0

			created_object.old_vel_x = 0
			created_object.old_vel_y = 0
			created_object.old_vel_z = 0

			created_object.noGravity = false
			created_object.grounded = false

			created_object.walking_frame = 1
			created_object.running_frame = 1

			created_object.facing = 1

			created_object.special_grounded = 0

			created_object.previous_frame = nil
			created_object.frame = nil
			created_object.next_frame = 1

			created_object.hit_code = ""

			created_object.wait = 0
			created_object.hit_timer = 0
			created_object.fall_timer = 0
			created_object.bdefend_timer = 0
			created_object.shaking = 0
			created_object.lying = false
			created_object.block_timer = 0
			created_object.arest = 0
			created_object.vrest = 0

			created_object.hp = created_object.head.hp
			created_object.mp = created_object.head.mp

			created_object.fall = created_object.head.fall
			created_object.bdefend = created_object.head.bdefend
			created_object.block = 0
			
			created_object.attackers = {}
			created_object.attacked = {}

			created_object.key_timer = {
				up = 0, down = 0, left = 0, right = 0,
				attack = 0, jump = 0, defend = 0, special1 = 0
			}

			created_object.double_key_timer = {
				up = 0, down = 0, left = 0, right = 0,
				attack = 0, jump = 0, defend = 0, special1 = 0
			}

			created_object.key_pressed = {
				up = 0, down = 0, left = 0, right = 0,
				attack = 0, jump = 0, defend = 0, special1 = 0
			}

			created_object.ai = false
			created_object.controller = 0
			created_object.team = -1
			created_object.owner = 0

			created_object.real_id = id
			created_object.dynamic_id = nil

			created_object.setFrame = entities.setFrame
			created_object.countersProcessing = entities.countersProcessing
			created_object.checkShaking = entities.checkShaking
			created_object.statesProcessing = entities.statesProcessing
			created_object.statesUpdate = entities.statesUpdate
			created_object.opointsProcessing = entities.opointsProcessing
			created_object.frameProcessing = entities.frameProcessing

			created_object.setController = battle.control.setController
			created_object.removeController = battle.control.removeController
			created_object.keysCheck = battle.control.keysCheck
			created_object.hit = battle.control.hit
			created_object.pressed = battle.control.pressed
			created_object.timer = battle.control.timer
			created_object.double_timer = battle.control.double_timer

			created_object.addToDrawing = battle.graphic.addToDrawing

			created_object.findCollaiders = battle.collision.findCollaiders
			created_object.getDTVal = battle.collision.getDTVal

			created_object.addMotion_X = battle.physix.addMotion_X
			created_object.addMotion_Y = battle.physix.addMotion_Y
			created_object.addMotion_Z = battle.physix.addMotion_Z

			created_object.setMotion_X = battle.physix.setMotion_X
			created_object.setMotion_Y = battle.physix.setMotion_Y
			created_object.setMotion_Z = battle.physix.setMotion_Z

			created_object.applyMotions = battle.physix.applyMotions
			created_object.applyGravity = battle.physix.applyGravity
			
			return created_object
		end
		return nil
	end



	function entities.spawnObject(id,x,y,z,facing,action,owner)
		if id ~= nil and action ~= nil then
			for i = 1, #entities.list + 1 do
				if entities.list[i] == nil then
					local object = entities.create(id)
					if object ~= nil then
						object.x = x
						object.y = y
						object.z = z
						object.facing = get.notNil(facing, 1)
						object.owner = get.notNil(owner, i)
						object.dynamic_id = i
						object:setFrame(action)
						entities.list[i] = object
						return object
					end
				end
			end
		end
		return nil
	end

	function entities.removeObjects(object)
		object:removeController()
		entities.list[object.dynamic_id] = nil
		return true
	end

	function entities:setFrame(f,i)
		if type(f) == "number" then
			if f == 0 and self.head.nextZero then
				if self.y > 0 then self:setFrame("air_standing")
				else self:setFrame("standing") end
				return true
			elseif f < 0 then
				self.facing = -self.facing
				f = -f
			end
			if self.frames[f] ~= nil then
				if self.frame ~= nil then
					self.previous_frame = self.frame
				end
				self.frame = self.frames[f]
				self.wait = self.frame.wait
				self.next_frame = self.frame.next
				return true
			else return false end
		elseif type(f) == "string" then
			if self.head.frames[f] ~= nil then
				if type(self.head.frames[f]) == "number" then
					self:setFrame(self.head.frames[f])
					return true
				elseif type(self.head.frames[f]) == "table" then
					if i ~= nil and i > 0 and i <= #self.head.frames[f] then
						self:setFrame(self.head.frames[f][i])
					else
						self:setFrame(self.head.frames[f][math.random(1,#self.head.frames[f])])
					end
				end
			else return false end
		else return false end
	end

	function entities:countersProcessing()
		self.gravity = self.head.gravity
		self.x_friction = self.head.gravity
		self.z_friction = self.head.gravity

		if self.bdefend_timer > 0 then self.bdefend_timer = self.bdefend_timer - 1
		else self.bdefend = self.head.bdefend end
		
		if self.fall_timer > 0 then self.fall_timer = self.fall_timer - 1
		else self.fall = self.head.fall end

		if self.arest > 0 then self.arest = self.arest - 1 end
		if self.vrest > 0 then self.vrest = self.vrest - 1 end
		if self.block_timer > 0 then self.block_timer = self.block_timer - 1 end

		if self.hit_timer > 0 then self.hit_timer = self.hit_timer - 1
		else self.hit_code = "" end
		
		if self.wait == self.frame.wait then self.first_tick = true
		else self.first_tick = false end
		
		entities.waitCounter(self)
	end

	function entities.waitCounter(object)
		if object.wait < 0 then object:setFrame(object.next_frame) else
			if object.shaking > 0 then object.shaking = object.shaking - 1
			else object.wait = object.wait - 1 end
		end
	end



	function entities:statesProcessing()
		for i = 1, #self.frame.states do
			if self.frame.states[i] ~= nil then
				local state = self.frame.states[i]
				if data.states[state.number] ~= nil and data.states[state.number].Processing ~= nil then
					data.states[state.number].variables = self.variables.states[state.number]
					data.states[state.number]:Processing(self,state)
				end
			end
		end
	end


	function entities:statesUpdate()
		for key, state in ipairs(self.head.states) do
			if data.states_update[state] ~= nil and data.states_update[state].Update ~= nil then
				data.states_update[state].variables = self.variables.states[state]
				data.states_update[state]:Update(self)
			end
		end
	end


	function entities:checkShaking()
		if self.shaking > 0 then return true
		else return false end
	end


	function entities:opointsProcessing()
		if self.first_tick then
			for i = 1, #self.frame.opoints do
				local opoint = self.frame.opoints[i]
				local amount = opoint.amount + math.random(0,opoint.amount_random)
				for a = 1, amount do
					local x = self.x - self.frame.centerx * self.facing + (opoint.x + math.random(-opoint.x_random, opoint.x_random)) * self.facing
					local y = self.y + self.frame.centery - opoint.y + math.random(-opoint.y_random, opoint.y_random)
					local z = self.z + opoint.z + math.random(-opoint.z_random, opoint.z_random)
					local count = opoint.count + math.random(0,opoint.count_random)
					local facing = opoint.facing
					if facing == 3 then facing = math.random(-1,1) end
					if facing == 0 then facing = 1 end
					for j = 1, count do
						local action = opoint.action + math.random(0,opoint.action_random)
						local object = entities.spawnObject(opoint.id, x, y, z, facing * self.facing, action, self.owner)
						if object ~= nil then
							object:setMotion_X((opoint.dvx + math.random(0,opoint.dvx_random * 100) * 0.01) * object.facing)
							object:setMotion_Y((opoint.dvy + math.random(0,opoint.dvy_random * 100) * 0.01))
							object:setMotion_Z((opoint.dvz + math.random(0,opoint.dvz_random * 100) * 0.01))
						end
					end
				end
			end
		end
	end



	function entities:frameProcessing()

		if self.grounded and self.frame.grounded ~= 0 then
			self:setFrame(self.frame.grounded)
		end

		if self.frame.dvx ~= 0 then self:setMotion_X(self.frame.dvx * self.facing) end
		if self.frame.dvy ~= 0 then self:setMotion_Y(self.frame.dvy) end
		if self.frame.dvz ~= 0 then self:setMotion_Z(self.frame.dvz) end

		self:addMotion_X(self.frame.dsx * self.facing)
		self:addMotion_Y(self.frame.dsy)
		self:addMotion_Z(self.frame.dsz)

		self.x = self.x + (self.frame.dx * self.facing)
		self.y = self.y + self.frame.dy
		self.z = self.z + self.frame.dz

	end

return entities