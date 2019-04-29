local collision = { }

	local abs = math.abs

	collision.list = {
		pending = { bodys = { }, itrs = { } },
		processed = { bodys = { }, itrs = { } }
	}

	--- Fill the collision list with colliders for current frame
	function collision:findColliders()
		self.attackers = { }
		self.attacked = { }

		if #self.frame.itrs > 0 then
			table.insert(collision.list.pending.itrs, self)
		end

		if #self.frame.bodys > 0 then
			table.insert(collision.list.pending.bodys, self)
		end
	end

	--- Check all pending collisions
	function collision.check()
		local kinds = data.kinds
		collision.list.processed = { itrs = { }, bodys = { } }
		for id1 = 1, #collision.list.pending.itrs do
			for id2 = 1, #collision.list.pending.bodys do
				local object = collision.list.pending.itrs[id1]
				local target = collision.list.pending.bodys[id2]
				if object.dynamic_id ~= target.dynamic_id and collision.isBoxesIntersected(object, target) then
					for i = 1, #object.frame.itrs do
						local itr = object.frame.itrs[i]
						for b = 1, #target.frame.bodys do
							local body = target.frame.bodys[b]
							if itr.frequency == body.frequency and
							   (not kinds[itr.kind].bodyCondition or kinds[itr.kind]:bodyCondition(object, target, itr, body)) and
							   collision.isCollidersIntersected(object, itr, target, body) then

								local processed = { attacker = object, damaged = target, itr = itr, body = body }
								table.insert(collision.list.processed.bodys, processed)
							end
						end -- for frame.bodys
					end -- for frame.itrs
				end -- if dynamic && boxes
			end -- for pending.bodys
		end -- for pending.itrs
		collision.list.pending = { bodys = { }, itrs = { } }
	end

	--- Execute kind.bodyProcessing for processed collisions
	function collision.processing()
		local kinds = data.kinds
		for i = 1, #collision.list.processed.bodys do
			local proc = collision.list.processed.bodys[i]
			if kinds[proc.itr.kind] and kinds[proc.itr.kind].bodyProcessing then
				kinds[proc.itr.kind]:bodyProcessing(proc.attacker, proc.damaged, proc.itr, proc.body)
			end
		end
	end

	--- Determine if objects' bounding boxes is intersected
	-- @param obj1, table  First object
	-- @param obj2, table  Second object
	-- @return boolean
	function collision.isBoxesIntersected(obj1, obj2)
		return abs(obj1.x - obj2.x) < obj1.frame.itrs.radius_x + obj2.frame.bodys.radius_x and
			   abs(obj1.y - obj2.y) < obj1.frame.itrs.radius_y + obj2.frame.bodys.radius_y and
			   abs(obj1.z - obj2.z) < obj1.frame.itrs.radius_z + obj2.frame.bodys.radius_z
	end

	--- Intersect colliders of specified objects
	-- @param obj1, table   First object
	-- @param coll1, table  First object's collider
	-- @param obj2, table   Second object
	-- @param coll2, table  Second object's collider
	-- @return boolean
	function collision.isCollidersIntersected(obj1, coll1, obj2, coll2)
		local c1x1 = obj1.x - obj1.frame.centerx * obj1.facing + coll1.x * obj1.facing
		local c1x2 = c1x1 + coll1.w * obj1.facing
		local c2x1 = obj2.x - obj2.frame.centerx * obj2.facing + coll2.x * obj2.facing
		local c2x2 = c2x1 + coll2.w * obj2.facing

		if get.Least(c1x1, c1x2) < get.Biggest(c2x1, c2x2) and get.Least(c2x1, c2x2) < get.Biggest(c1x1, c1x2) then
			local c1z1 = obj1.z + coll1.z
			local c1z2 = c1z1 + coll1.l
			local c2z1 = obj2.z + coll2.z
			local c2z2 = c2z1 + coll2.l

			if get.Least(c1z1, c1z2) < get.Biggest(c2z1, c2z2) and get.Least(c2z1, c2z2) < get.Biggest(c1z1, c1z2) then
				local c1y1 = obj1.y + obj1.frame.centery - coll1.y
				local c1y2 = c1y1 - coll1.h
				local c2y1 = obj2.y + obj2.frame.centery - coll2.y
				local c2y2 = c2y1 - coll2.h
				return get.Least(c1y1, c1y2) < get.Biggest(c2y1, c2y2) and get.Least(c2y1, c2y2) < get.Biggest(c1y1, c1y2)
			end
		end

		return false
	end

	--- Calculate center / median point of two colliders
	-- @param obj1, table   First object
	-- @param coll1, table  First object's collider
	-- @param obj2, table   Second object
	-- @param coll2, table  Second object's collider
	-- @return { int, int }
	function collision.calculateCenter(obj1, coll1, obj2, coll2)
		local x = { }
		x[1] = obj1.x - obj1.frame.centerx * obj1.facing + coll1.x * obj1.facing
		x[2] = x[1] + coll1.w * obj1.facing
		x[3] = obj2.x - obj2.frame.centerx * obj2.facing + coll2.x * obj2.facing
		x[4] = x[3] + coll2.w * obj2.facing

		local y = {}
		y[1] = obj1.y + obj1.frame.centery - coll1.y
		y[2] = y[1] - coll1.h
		y[3] = obj2.y + obj2.frame.centery - coll2.y
		y[4] = y[3] - coll2.h

		for i = 1, 4 do
			for j = 1, 4 do
				if x[j] > x[i] then
	 	 			x[i], x[j] = x[j], x[i]
	 	 		end
	 	 		if y[j] > y[i] then
	 	 			y[i], y[j] = y[j], y[i]
	 	 		end
			end
		end

		local collision_center_x = (x[2] + x[3]) / 2
 		local collision_center_y = (y[2] + y[3]) / 2
 	
 		return collision_center_x, collision_center_y
	end

return collision