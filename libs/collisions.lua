collisioners = {} -- массив с информацией о всех претендентах на проверку коллизий
collisioners.itr = {}
collisioners.body = {}
collisioners.platform = {}

collisions_list = {}


function CollisionersProcessing()
	collisions_list = {}

	for i = 1, #collisioners.itr do
		local entity = entity_list[collisioners.itr[i]]
		local entity_frame = GetFrame(entity)
		
		for j = 1, #collisioners.body do
			if collisioners.itr[i] ~= collisioners.body[j] then
				local target = entity_list[collisioners.body[j]]
				local target_frame = GetFrame(target)
				local distantion = GetDistance(entity.x, entity.y, target.x, target.y)
				if distantion < (entity_frame.itr_radius + target_frame.body_radius) then
					for itr_id = 1, #entity_frame.itrs do
						local itr = CollaiderCords(entity_frame.itrs[itr_id], entity.x, entity.y, entity.z, entity_frame.centerx, entity_frame.centery, entity.facing)
						for body_id = 1, #target_frame.bodys do
							local body = CollaiderCords(target_frame.bodys[body_id], target.x, target.y, entity.z, target_frame.centerx, target_frame.centery, target.facing)
							
							if entity.z + itr.z * 0.5 > target.z and entity.z - itr.z * 0.5 < target.z then
								if (CheckCollision(itr, body)) then
									local collision = {
										type = "itr_to_body",
										entity_id = collisioners.itr[i],
										target_id = collisioners.body[j],
										entity_frame = entity.frame,
										target_frame = target.frame,
										itr_id = itr_id,
										body_id = body_id
									}
									table.insert(collisions_list, collision)
								end
							end
						end
					end
				end
			end
		end
		
		for j = i + 1, #collisioners.itr do
			local target = entity_list[collisioners.itr[j]]
			local target_frame = GetFrame(target)
			local distantion = GetDistance(entity.x, entity.y, target.x, target.y)
			if distantion < (entity_frame.itr_radius + target_frame.itr_radius) then
				for itr1_id = 1, #entity_frame.itrs do
					local itr1 = CollaiderCords(entity_frame.itrs[itr1_id], entity.x, entity.y, entity.z, entity_frame.centerx, entity_frame.centery, entity.facing)
					for itr2_id = 1, #target_frame.itrs do
						local itr2 = CollaiderCords(target_frame.itrs[itr2_id], target.x, target.y, entity.z, target_frame.centerx, target_frame.centery, target.facing)
						
						if (entity.z + itr1.z * 0.5 > target.z and entity.z - itr1.z * 0.5 < target.z) or (target.z + itr2.z * 0.5 > entity.z and target.z - itr2.z * 0.5 < entity.z) then
							if (CheckCollision(itr1, itr2)) then
								local collision = {
									type = "itr_to_itr",
									entity_id = collisioners.itr[i],
									target_id = collisioners.itr[j],
									entity_frame = entity.frame,
									target_frame = target.frame,
									itr1_id = itr1_id,
									itr2_id = itr2_id
								}
								table.insert(collisions_list, collision)
							end
						end
					end
				end
			end
		end
	end


	if #collisioners.platform > 0 then
		for en_id = 1, #entity_list do
			local entity = entity_list[en_id]
			local entity_frame = GetFrame(entity)
			for j = 1, #collisioners.platform do
				if en_id ~= collisioners.platform[j] then
					local target = entity_list[collisioners.platform[j]]
					local target_frame = GetFrame(target)
					local distantion = GetDistance(entity.x, entity.y, target.x, target.y)
					if distantion < target_frame.platform_radius then
						for p_id = 1, #target_frame.platforms do

							local platform = CollaiderCords(target_frame.platforms[p_id], target.x, target.y, target.z, target_frame.centerx, target_frame.centery, target.facing)

							if (entity.x < platform.x + platform.w and entity.x > platform.x and entity.z < target.z + (platform.z * 0.5) and entity.z > target.z - (platform.z * 0.5) and map.border_up - entity.y < platform.y and map.border_up - entity.y > platform.y - platform.h) then
								local collision = {
									type = "unit_to_platform",
									entity_id = collisioners.platform[j],
									target_id = en_id,
									platform_id = p_id
								}
								table.insert(collisions_list, collision)
							end
						end
					end
				end
			end
		end
	end
	
	collisioners.itr = {}
	collisioners.body = {}
	collisioners.platform = {}

end



function CheckCollision(c1,c2)
	return c1.x < c2.x + c2.w and c2.x < c1.x + c1.w and c1.y < c2.y + c2.h and c2.y < c1.y + c1.h
end


function CollaiderCords(collaider, x, y, z, centerx, centery, facing)
	local real_cords = {
		x,
		y = map.border_up + collaider.y - y + z - centery,
		w = collaider.w,
		h = collaider.h,
		z = collaider.z
	}
	if facing == 1 then 
		real_cords.x = x + (collaider.x - centerx)
	else
		real_cords.x = x - (collaider.x - centerx) - collaider.w
	end
	return real_cords
end




function CollisionsProcessing()

	for c_id = 1, #collisions_list do
	local collision = collisions_list[c_id]

		if collision.type == "itr_to_body" then -- обработка удара itr'a по body
			
			local attacker = entity_list[collision.entity_id] -- получаем атакующего
			local target = entity_list[collision.target_id] -- получаем получающего урон
			local itr = attacker.frames[collision.entity_frame].itrs[collision.itr_id] -- получаем itr
			local body = attacker.frames[collision.target_frame].bodys[collision.body_id] -- получаем body

			if itr.kind == 1 then -- если kind: 1 (обычная атака)
				attacker.arest = itr.arest -- установка таймера до следующего нанесения урона атакующим
				target.vrest = itr.vrest -- установка таймера до следующего получения урона целью
				target.defend = target.defend - itr.bdefend -- уменьшаем броню цели
				target.defend_timer = target.defend_timer + 60 -- добавляем таймер восстановления к броне
				if target.defend <= 0 then -- если пробили броню
					target.defend_timer = target.defend_timer + 60 -- добавляем бонусный таймер восстановления к броне
					target.fall = target.fall - itr.fall -- уменьшение fall'a
					if target.fall <= 0 then -- если fall пробит
						target.fall = target.max_fall -- моментально восстанавливаем fall
						target.fall_timer = 0 -- обнуляем таймер

						-- ПАДЕНИЕ --

					else -- если fall не пробит
						target.fall_timer = 120 -- таймер восстанавления fall'a

						target.taccel_x = target.taccel_x + itr.dvx * attacker.facing -- dvx

						local injury_frame = 0 -- ставим кадр повреждений

						if #target.injury_frames > 0 then -- берём рандомный кадр повреждения из списка
							injury_frame = target.injury_frames[math.random(1, #target.injury_frames)]
						end

						if math.abs(itr.dvx) >= 5 then -- если удар спереди\\сзади и у цели имеются спец. кадры повреждений на этот случай, меняем кадр повреждения
							if target.facing == attacker.facing then
								if target.injury_backward_frame ~= 0 then
									injury_frame = target.injury_backward_frame
								end
							else
								if target.injury_forward_frame ~= 0 then
									injury_frame = target.injury_forward_frame
								end
							end
						end

						if itr.damage_type > 0 and #target.injury_types >= itr.damage_type then -- для специальных типов урона используем свои кадры повреждения
							injury_frame = target.injury_types[itr.damage_type]
						end

						SetFrame(target, injury_frame)
					end
				else -- если броня не пробита
					target.taccel_x = target.taccel_x + ( itr.dvx * attacker.facing ) * 0.9
				end
			end
		end
	end
end


function CollaidersFind (en_id)

	local en = entity_list[en_id]
	local frame = GetFrame(en)

	if en.collision then -- если коллизии включены, выполняется проверка на наличие коллайдеров в текущем кадре. если коллайдеры имеются, они заносятся в списки для дальнейшей обработки
		if (en.arest == 0) and (frame.itr_radius > 0) then
			table.insert(collisioners.itr, en_id)
		end
		if (en.vrest == 0) and (frame.body_radius > 0) then
			table.insert(collisioners.body, en_id)
		end
		if (frame.platform_radius > 0) then
			table.insert(collisioners.platform, en_id)
		end
	end

end