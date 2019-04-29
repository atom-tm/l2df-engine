local kind = {}

	function kind:loadingBody(body, body_data)
		body.static 			= get.PBool(body_data,"static")
		body.participle 		= get.PBool(body_data,"participle")
		body.damaged_frame 		= get.PNumber(body_data,"damaged_frame")

		return body
	end


	function kind:loadingInfo(itr, itr_data)
		itr.team 				= get.PNumber(itr_data, "team", 1)
		itr.dtype 				= get.PNumber(itr_data, "dtype", 0)

		itr.injury 				= get.PNumber(itr_data, "injury")
		itr.mana_injury 		= get.PNumber(itr_data, "mana_injury")
		itr.bdefend 			= get.PNumber(itr_data, "bdefend")
		itr.fall 				= get.PNumber(itr_data, "fall")
		itr.arest				= get.PNumber(itr_data, "arest", 10)
		itr.vrest 				= get.PNumber(itr_data, "vrest", 15)

		itr.dvx 				= get.PNumber(itr_data, "dvx", 0)
		itr.dvy 				= get.PNumber(itr_data, "dvy", 0)
		itr.dvz 				= get.PNumber(itr_data, "dvz")

		itr.static 				= get.PBool(itr_data, "static")
		itr.reflection 			= get.PBool(itr_data, "reflection")
		itr.x_repulsion 		= get.PBool(itr_data, "x_repulsion")
		itr.y_repulsion 		= get.PBool(itr_data, "y_repulsion")
		itr.x_stop		 		= get.PBool(itr_data,  "x_stop")

		itr.level				= get.PNumber(itr_data, "level", 1)
		itr.not_knocking_down 	= get.PBool(itr_data, "not_knocking_down")
		itr.attacker_frame 		= get.PNumber(itr_data, "aframe")
		itr.damaged_frame 		= get.PNumber(itr_data, "dframe")

		itr.no_shaking 			= get.PBool(itr_data, "no_shaking")
		itr.stun 	 			= get.PNumber(itr_data, "stun")

		itr.no_spark 			= get.PBool(itr_data, "no_spark")
		
		return itr
	end


	function kind:bodyCondition(attacker, defender, itr, body)
		if attacker.arest > 0 or defender.vrest > 0 then return false end

		if itr.team == -1 then
			return attacker.team == -1 and attacker.owner == defender.owner or attacker.team == defender.team
		end
		return attacker.team == -1 and attacker.owner ~= defender.owner or attacker.team ~= defender.team
	end


	function kind:bodyProcessing(attacker, defender, itr, body)
		local dtype = defender.head.dtypes[tostring(itr.dtype)]

		local broken_block = false
		local broken_defend = false

		local spark = 0
		local frame = 0

		if not itr.static then attacker.shaking = 2 end
		if not body.static then defender.shaking = 2 end

		defender.bdefend_timer = defender.head.bdefend_timer
		defender.fall_timer = defender.head.fall_timer
		attacker.arest = itr.arest
		defender.vrest = itr.vrest
		
		table.insert(defender.attackers, attacker)
		table.insert(attacker.attacked, defender)
		attacker.combo = attacker.combo + 1
		attacker.combo_timer = 70

		local backstab = attacker.facing == defender.facing

		if defender.block > 0 then
			if not backstab then
				defender.block = defender.block - itr.bdefend
			else defender.block = 0 end
			if defender.block <= 0 then
				broken_block = true
				defender.block_timer = defender.block_timer + itr.bdefend + 10
				defender.bdefend = defender.bdefend + defender.block
			end
		else
			if defender.bdefend > 0 then
				defender.bdefend = defender.bdefend - itr.bdefend
				if defender.bdefend <= 0 then broken_defend = true end
			end
		end

		if defender.bdefend + defender.block <= 0 then
			
			defender.bdefend = 0
			defender.block = 0

			defender.hp = defender.hp - itr.injury
			defender.mp = defender.mp - itr.mana_injury
			defender.fall = defender.fall - itr.fall

			if defender.fall <= 0 and (not itr.not_knocking_down or defender.lying) then
				if backstab then frame = dtype:Get("falling_backstab")
				else frame = dtype:Get("falling") end
				if defender.head.type == "character" then spark = dtype:Get("fall_spark")
				elseif defender.head.type == "object" then spark = dtype:Get("object_fall_spark") end
			else			
				if broken_block then
					if backstab then frame = dtype:Get("bdefend_backstab")
					else frame = dtype:Get("bdefend") end
					spark = dtype:Get("bblock_spark")
				elseif broken_defend then
					if backstab then frame = dtype:Get("injury_backstab")
					else frame = dtype:Get("injury") end
					spark = dtype:Get("bdefend_spark")
				else
					if backstab then frame = dtype:Get("injury_backstab")
					else frame = dtype:Get("injury") end
					if defender.head.type == "character" then spark = dtype:Get("injury_spark") 
					elseif defender.head.type == "object" then spark = dtype:Get("object_injury_spark") end
				end
			end

			if itr.defender_frame ~= 0 then frame = itr.defender_frame end
			if body.defender_frame ~= 0 then frame = body.defender_frame end

		else -- defender.bdefend + defender.block > 0

			if not body.static then defender.shaking = defender.shaking + 2 end
			if not itr.static then attacker.shaking = attacker.shaking + 2 end

			local de = dtype:Get("defend_efficiency")
			if de == 0 then de = 0.5 end
			defender.hp = defender.hp - math.floor(itr.injury * de)
			defender.mp = defender.mp - math.floor(itr.mana_injury * de)

			if broken_block then
				if backstab then
					frame = dtype:Get("bdefend_backstab")
					spark = dtype:Get("bblock_spark")
				else
					frame = dtype:Get("bdefend")
					spark = dtype:Get("defend_spark")
				end
			else
				if defender.block > 0 then spark = dtype:Get("block_spark")
				else spark = dtype:Get("defend_spark") end
			end

		end

		if not itr.no_shaking and (attacker.controller > 0 or defender.controller > 0) then
			battle.graphic.camera_settings.shaking = math.ceil((itr.injury + itr.fall + itr.bdefend) / 45) * 6 
		end

		if not body.static then
			defender:addMotion_X(itr.dvx * attacker.facing)
			defender:addMotion_Z(itr.dvz)
			if itr.x_repulsion then defender:addMotion_X(attacker.vel_x) end
			if defender.bdefend + defender.block > 0 then
	 			defender:setMotion_X(defender.vel_x * 0.7)
	 			defender:setMotion_Z(defender.vel_z * 0.7)
			end
			if defender.fall <= 0 and (not itr.not_knocking_down or defender.lying) then defender:addMotion_Y(itr.dvy) end
			if itr.x_stop then attacker:setMotion_X(0) end
		end

		if frame ~= 0 then defender:setFrame(frame) end
		if itr.attacker_frame ~= 0 then attacker:setFrame(itr.attacker_frame) end

		if not body.static and defender.bdefend + defender.block <= 0 then defender.wait = defender.wait + itr.stun end

		if spark ~= 0 and not itr.no_spark then
			local spark_x, spark_y = battle.collision.calculateCenter(attacker, itr, defender, body)
			local sprk = battle.entities.spawnObject(data.system["sparks"], spark_x, spark_y, defender.z + 5, attacker.facing, spark, attacker.owner)
			if sprk then sprk.target = defender end
		end
	end


	function kind:itrCondition(attacker, defender, itr1, itr2)
		-- pass
	end


	function kind:itrProcessing(attacker, defender, itr1, itr2)
		-- pass
	end

return kind