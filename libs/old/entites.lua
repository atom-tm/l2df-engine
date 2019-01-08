function SetFrame(en, frame)

	if frame ~= nil and en ~= nil then
		
		if frame < 0 then
			en.facing = -en.facing
			frame = -frame
		end -- разворот объекта, если фрейм указан со знаком минуса

		if frame == 999 or frame == 0 then
			if en.y > 0 and en.on_platform == false then -- если объект в воздухе и не на платформе
				frame = NotZero(en.air_frame, NotZero(en.idle_frame))
			else
				frame = NotZero(en.idle_frame)
			end
		elseif frame == 1000 then
			en.destroy_flag = true
			return -- уничтожение объекта
		else
			if en.frames[frame] == nil then
				if en.y > 0 and en.on_platform == false then -- если объект в воздухе и не на платформе
					frame = NotZero(en.air_frame, NotZero(en.idle_frame))
				else
					frame = NotZero(en.idle_frame)
				end
			end
		end

		local new_frame = GetFrame(en, frame)
		en.previous_frame = en.frame
		en.frame = frame
		en.wait = new_frame.wait
		en.next_frame = new_frame.next
		en.first_tick_flag = true
	end

	--[[if frame_num == 999 or frame_num == 0 then
		if not (en.y > 0 and en.on_platform == false) then
			if en.idle_frame ~= 0 then
				frame_num = en.idle_frame
			else
				for i = 1, #en.frames do
					if en.frames[i] ~= nil then
						frame_num = i
						break
					end
				end
			end
		else
			if en.air_frame ~= 0 then
				frame_num = en.air_frame
			end
		end
	elseif frame_num == 1000 then

	end

	if en.frames[frame_num] ~= nil then
		en.frame = frame_num
		local frame = GetFrame(en)
		en.wait = frame.wait
		en.next_frame = frame.next
		en.first_tick_flag = true
	end]]--
end

function OpointProcessing(en_id)
	local en = entity_list[en_id]
	local frame = GetFrame(en)

	for i = 1, #frame.opoints do

		local opoint = frame.opoints[i]
		local id = opoint.id

		local x = en.x + opoint.x * en.facing + math.random(-(opoint.x_random * 0.5), (opoint.x_random * 0.5))
		local y = en.y + opoint.y + math.random(-(opoint.y_random * 0.5), (opoint.y_random * 0.5))
		local z = en.z + opoint.z + math.random(-(opoint.z_random * 0.5), (opoint.z_random * 0.5))

		local facing = opoint.facing

		if en.facing == -1 then facing = -facing end
		if facing == 0 then facing = en.facing end

		local action = opoint.action + math.random(0, opoint.action_random)

		if opoint.count%2 == 0 then

			local z_offset = 15
			for i = 1, opoint.count do
				if i%2 == 0 then
					SpawnEntity(id, x, y, z + z_offset, facing, action, en.owner)
					z_offset = z_offset + 15
				else
					SpawnEntity(id, x, y, z - z_offset, facing, action, en.owner)
				end
			end
		else
			
			local z_offset = 0
			
			for i = 1, opoint.count do
				if i%2 == 0 then
					SpawnEntity(id, x, y, z + z_offset, facing, action, en.owner)
				else
					SpawnEntity(id, x, y, z - z_offset, facing, action, en.owner)
					z_offset = z_offset + 15
				end
			end

		end
	end
end


function SpawnEntity(id, x, y, z, facing, action, owner)
	new_object = CreateEntity(id)
	if new_object ~= false then
		en = entity_list[new_object]
		en.x = x
		en.y = y
		en.z = z
		if facing == 0 then 
			en.facing = 1
		else
			en.facing = facing
		end
		SetFrame(en, action)
		if owner ~= nil then
			en.owner = entity_list[owner].owner
			en.team = entity_list[owner].team
		end
		return new_object
	else
		return false
	end
end
