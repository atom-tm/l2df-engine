function SetFrame(en, frame)
	
	local frame_num = frame

	if frame_num == 999 or frame_num == 0 then 
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
	end

	if en.frames[frame_num] ~= nil then
		en.frame = frame_num
		local frame = GetFrame(en)
		en.wait = frame.wait
		en.next_frame = frame.next
		en.first_tick_flag = true
	end
end

function OpointProcessing(en_id)
	local en = entity_list[en_id]
	local frame = GetFrame(en)

	for i = 1, #frame.opoints do

		local opoint = frame.opoints[i]
		local id = opoint.id



		local x = en.x + opoint.x * en.facing
		local y = en.y + opoint.y
		local z = en.z + opoint.z

		local facing = opoint.facing

		if en.facing == -1 then facing = -facing end
		if facing == 0 then facing = en.facing end

		local action = opoint.action


		Spawn(id, x, y, z, facing, action)

	end
end


function Spawn(id, x, y, z, facing, action)
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
		return new_object
	else
		return false
	end
end

