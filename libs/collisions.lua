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
							local unit = {
								x = entity.x,
								y = map.border_up - entity.y + entity.z,
								w = 1,
								h = 1,
								z = 1
							}
							if (CheckCollision(platform, unit)) then
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

			if collision.type == "unit_to_platform" then
				
			end

	end

end