local collision = {}

	collision.list = { 
		general = { bodys = {}, itrs = {} },
		processed = { bodys = {}, itrs = {} }
	}

	function collision:findCollaiders()
		self.attackers = {} self.attacked = {}
		if #self.frame.itrs > 0 then table.insert(collision.list.general.itrs, self) end
		if #self.frame.bodys > 0 then table.insert(collision.list.general.bodys, self) end
	end

	function collision.check()
		collision.list.processed = { itrs = {}, bodys = {} }
		for id1 = 1, #collision.list.general.itrs do
			for id2 = 1, #collision.list.general.bodys do
				local object = collision.list.general.itrs[id1]
				local target = collision.list.general.bodys[id2]
				if object.dynamic_id ~= target.dynamic_id then
					if
					math.abs(object.x - target.x) < object.frame.itrs.radius_x + target.frame.bodys.radius_x and
					math.abs(object.y - target.y) < object.frame.itrs.radius_y + target.frame.bodys.radius_y and
					math.abs(object.z - target.z) < object.frame.itrs.radius_z + target.frame.bodys.radius_z
					then
						for i = 1, #object.frame.itrs do
							local itr = object.frame.itrs[i]
							for b = 1, #target.frame.bodys do
								local body = target.frame.bodys[b]
								if itr.frequency == body.frequency then
									if (data.kinds[itr.kind].bodyCondition == nil) or (data.kinds[itr.kind]:bodyCondition(object, target, itr, body) == true) then
										if collision.compareCollaiders(object, itr, target, body) then
											local processed = { attacker = object, damaged = target, itr = itr, body = body }
											table.insert(collision.list.processed.bodys, processed)
										end
									end
								end
							end
						end
					end
				end
			end
		end
		collision.list.general = { bodys = {}, itrs = {} }
	end

	function collision.processing()
		for i = 1, #collision.list.processed.bodys do
			local proc = collision.list.processed.bodys[i]
			if data.kinds[proc.itr.kind] and data.kinds[proc.itr.kind].bodyProcessing then
				data.kinds[proc.itr.kind]:bodyProcessing(proc.attacker, proc.damaged, proc.itr, proc.body)
			end
		end
	end

	function collision.compareCollaiders(object1, collaider1, object2, collaider2)
		local c1x1 = object1.x - object1.frame.centerx * object1.facing + collaider1.x * object1.facing
		local c1x2 = c1x1 + collaider1.w * object1.facing
		local c2x1 = object2.x - object2.frame.centerx * object2.facing + collaider2.x * object2.facing
		local c2x2 = c2x1 + collaider2.w * object2.facing
		if (get.Least(c1x1, c1x2) < get.Biggest(c2x1, c2x2)) and (get.Least(c2x1, c2x2) < get.Biggest(c1x1, c1x2)) then
			local c1z1 = object1.z + collaider1.z
			local c1z2 = c1z1 + collaider1.l
			local c2z1 = object2.z + collaider2.z
			local c2z2 = c2z1 + collaider2.l
			if (get.Least(c1z1, c1z2) < get.Biggest(c2z1, c2z2)) and (get.Least(c2z1, c2z2) < get.Biggest(c1z1, c1z2)) then
				local c1y1 = object1.y + object1.frame.centery - collaider1.y
				local c1y2 = c1y1 - collaider1.h
				local c2y1 = object2.y + object2.frame.centery - collaider2.y
				local c2y2 = c2y1 - collaider2.h
				if (get.Least(c1y1, c1y2) < get.Biggest(c2y1, c2y2)) and (get.Least(c2y1, c2y2) < get.Biggest(c1y1, c1y2)) then
					return true
				else return false end
			else return false end
		else return false end
	end

	function collision.centerCalculate(object1, collaider1, object2, collaider2)
		local x = {}
		x[1] = object1.x - object1.frame.centerx * object1.facing + collaider1.x * object1.facing
		x[2] = x[1] + collaider1.w * object1.facing
		x[3] = object2.x - object2.frame.centerx * object2.facing + collaider2.x * object2.facing
		x[4] = x[3] + collaider2.w * object2.facing
		local y = {}
		y[1] = object1.y + object1.frame.centery - collaider1.y
		y[2] = y[1] - collaider1.h
		y[3] = object2.y + object2.frame.centery - collaider2.y
		y[4] = y[3] - collaider2.h

		for i = 1, 4 do
			for j = 1, 4 do
				if x[j] > x[i] then
	 	 			local xv = x[j]
	 	 			x[j] = x[i]
	 	 			x[i] = xv
	 	 		end
	 	 		if y[j] > y[i] then
	 	 			local yv = y[j]
	 	 			y[j] = y[i]
	 	 			y[i] = yv
	 	 		end
			end
		end

		local collision_center_x = (x[2] + x[3]) / 2
 		local collision_center_y = (y[2] + y[3]) / 2
 	
 		return collision_center_x, collision_center_y
	end


return collision