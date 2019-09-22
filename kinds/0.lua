local kind = {}

function kind:Start(attacker, itr, damaged, body)

	if attacker.arest == 0 and damaged.vrest == 0 then
		
		if (itr.purpose == 1 and ((attacker.team ~= damaged.team) or attacker.team == -1 or damaged.team == -1) and attacker.owner ~= damaged.owner)
		or (body.participle)
		or (itr.purpose == 0)
		or (itr.purpose == -1 and (attacker.team == damaged.team) and (attacker.team ~= -1 or damaged.team ~= -1)) then

			local dtype = itr.dtype

			local broken_block = false
			local broken_defend = false

			local spark = nil
			local frame = nil

			if not itr.static then attacker.shaking = 2 end
			if not body.static then damaged.shaking = 2 end

			damaged.bdefend_timer = 160
			damaged.fall_timer = 100
			attacker.arest = itr.arest
			damaged.vrest = itr.vrest

			table.insert(damaged.attackers, attacker)
			table.insert(attacker.attacked, damaged)

			if damaged.block > 0 then
				if attacker.facing ~= damaged.facing then
					damaged.block = damaged.block - itr.bdefend
				else damaged.block = 0 end
				if damaged.block <= 0 then
					broken_block = true
					damaged.bdefend = damaged.bdefend + damaged.block
				end
			else
				if damaged.bdefend > 0 then
					damaged.bdefend = damaged.bdefend - itr.bdefend
					if damaged.bdefend <= 0 then broken_defend = true end
				end
			end

			if damaged.bdefend + damaged.block <= 0 then
				
				damaged.bdefend = 0
				damaged.block = 0

				if not body.static then
					if itr.reflection then
						damaged:setMotion_X(damaged.vel_x)
						if damaged.x <= attacker.x then damaged:addMotion_X(-itr.dvx)
						elseif damaged.x > attacker.x then damaged:addMotion_X(itr.dvx) end
					else
						damaged:addMotion_X(itr.dvx * attacker.facing)
						if itr.x_repulsion then damaged:addMotion_X(attacker.vel_x) end
					end
				end

				damaged.fall = damaged.fall - itr.fall
				if damaged.fall <= 0 and (not itr.not_knocking_down or damaged.lying) then
					if not body.static then
						damaged:addMotion_Y(itr.dvy)
					end
					if attacker.facing ~= damaged.facing then frame = damaged:getDTVal(dtype, "falling_backward")
					else frame = damaged:getDTVal(dtype, "falling_forward") end
					if damaged.head.type == "character" then
						spark = damaged:getDTVal(dtype, "fall_spark")
					elseif damaged.head.type == "object" then
						spark = damaged:getDTVal(dtype, "object_fall_spark")
					end

				else
					if broken_block then
						if attacker.facing ~= damaged.facing then frame = damaged:getDTVal(dtype, "bdefend_backward")
						else frame = damaged:getDTVal(dtype, "bdefend_forward") end
						spark = damaged:getDTVal(dtype, "bblock_spark")
					elseif broken_defend then
						if attacker.facing ~= damaged.facing then frame = damaged:getDTVal(dtype, "injury_backward")
						else frame = damaged:getDTVal(dtype, "injury_forward") end
						spark = damaged:getDTVal(dtype, "bdefend_spark")
					else
						if attacker.facing ~= damaged.facing then frame = damaged:getDTVal(dtype, "injury_backward")
						else frame = damaged:getDTVal(dtype, "injury_forward") end
						if damaged.head.type == "character" then
							spark = damaged:getDTVal(dtype, "injury_spark")
						elseif damaged.head.type == "object" then
							spark = damaged:getDTVal(dtype, "object_injury_spark")
						end
					end
				end

				if itr.damaged_frame ~= 0 then frame = itr.damaged_frame end
				if body.damaged_frame ~= 0 then frame = body.damaged_frame end
				
			elseif damaged.bdefend + damaged.block > 0 then
				if not body.static then
					if itr.reflection then
						damaged:setMotion_X(damaged.vel_x)
						if damaged.x <= attacker.x then damaged:addMotion_X(-itr.dvx * 0.55)
						elseif damaged.x > attacker.x then damaged:addMotion_X(itr.dvx * 0.55) end
					else
						damaged:addMotion_X(itr.dvx * attacker.facing * 0.55)
						if itr.x_repulsion then damaged:addMotion_X(attacker.vel_x) end
					end
					damaged.shaking = damaged.shaking + 2
				end
				if not itr.static then
					attacker.shaking = attacker.shaking + 2
				end
				damaged.fall = damaged.fall - math.floor(itr.fall * 0.55)

				if broken_block then
					if attacker.facing ~= damaged.facing then
						frame = damaged:getDTVal(dtype, "bdefend_backward")
						spark = damaged:getDTVal(dtype, "bblock_spark")
					else
						frame = damaged:getDTVal(dtype, "bdefend_forward")
						spark = damaged:getDTVal(dtype, "defend_spark")
					end
				else
					if damaged.block > 0 then
						spark = damaged:getDTVal(dtype, "block_spark")
					else
						spark = damaged:getDTVal(dtype, "defend_spark")
					end
				end
			end
			
			if frame ~= nil then
				damaged:setFrame(frame)
			end

			if itr.attacker_frame ~= 0 then attacker:setFrame(itr.attacker_frame) end

			if spark ~= nil then
				local spark_x, spark_y = battle.collision.centerCalculate(attacker, itr, damaged, body)
				battle.entities.spawnObject(data.system["sparks"],spark_x,spark_y,damaged.z + 5,attacker.facing,spark,attacker.owner)
			end

		end
	end
end

return kind