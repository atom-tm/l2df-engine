function BattleProcessing(...)
	for en_id = 1, #entity_list do
		local en = entity_list[en_id]
		local frame = GetFrame(en)

		hit_Check(en, frame)

		if en.wait == 0 then
			SetFrame(en, en.next_frame)
		else en.wait = en.wait - 1 end

		if en.physic == true then
			Gravity(en_id)
		end

		if (en.vel_x ~= 0) or (en.vel_y ~= 0) then
			Motion(en, dt)
		end

		if en.collision then
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
		en.in_air = true
	end
end