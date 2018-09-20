collisioners = {} -- массив с информацией о всех претендентах на проверку коллизий
collisioners.itr = {}
collisioners.body = {}
collisioners.platform = {}

collisions_list = {}

function CollisionersProcessing()
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
						itr = entity_frame.itrs[itr_id]
						for body_id = 1, #target_frame.bodys do
							body = target_frame.bodys[body_id]
							if (CheckCollision(itr, body)) then
								collision = {
									entity_id = collisioners.itr[i],
									target_id = collisioners.body[j],
									itr_id = itr_id,
									body_id = body_id
								}
								table.insert(collisions_list, collision)
	end	end	end	end	end	end	end
	collisioners.itr = {}
	collisioners.body = {}
	collisioners.platform = {}
end

function CheckCollision(c1,c2)
  return c1.x < c2.x + c2.w and c2.x < c1.x + c1.w and c1.y < c2.y + c2.h and c2.y < c1.y + c1.h
end

function CollaiderCords(collaider, x, y, centerx, centery, facing)
	local real_cords = {
		x = collaider.x + x - centerx,
		y = collaider.y + y - centery,
		w = collaider.w,
		h = collaider.h
	}
	if facing ~= 1 then real_cords.x = real_cords.x - real_cords.w end
	return real_cords
end