function StatesCheck(en_id)

	local en = entity_list[en_id]
	local frame = GetFrame(en)

	for i = 1, #frame.states do
		local state = frame.states[i]
		t1 = state.num
		

		if state.num == "1" then -- стойка
			if en.key_pressed["left"] > 0 or en.key_pressed["up"] > 0 or en.key_pressed["down"] > 0 or en.key_pressed["right"] > 0 then
				SetFrame(en, en.walking_frames[en.walking_frame])
			end -- если нажаты клавиши управления, переход в кадры ходьбы
			if (en.double_key_timer["left"] == 25 and en.facing == -1) or (en.double_key_timer["right"] == 25 and en.facing == 1) then
				SetFrame(en, en.running_frames[en.running_frame])
			end -- если дважды нажаты клавиши управления, переход в кадры бега
		end


		if state.num == "2" then -- ходьба
			if en.wait <= 0 then
				if en.walking_frame == #en.walking_frames then
					en.walking_frame = 1
				else
					en.walking_frame = en.walking_frame + 1
				end
			end
			if en.key_pressed["left"] > 0 then
				en.facing = -1
				en.accel_x = en.walking_speed_x * en.facing
				en.next_frame = en.walking_frames[en.walking_frame]
			elseif en.key_pressed["right"] > 0 then
				en.facing = 1
				en.accel_x = en.walking_speed_x * en.facing
				en.next_frame = en.walking_frames[en.walking_frame]
			end
			if en.key_pressed["up"] > 0 then
				en.accel_z = en.walking_speed_z * -1
				en.next_frame = en.walking_frames[en.walking_frame]
			elseif en.key_pressed["down"] > 0 then
				en.accel_z = en.walking_speed_z * 1
				en.next_frame = en.walking_frames[en.walking_frame]
			end

			if (en.double_key_timer["left"] == 25 and en.facing == -1) or (en.double_key_timer["right"] == 25 and en.facing == 1) then
				SetFrame(en, en.running_frames[en.running_frame])
			end -- если дважды нажаты клавиши управления, переход в кадры бега
		end

		if state.num == "3" then -- бег
			if en.wait <= 0 then
				if en.running_frame == #en.running_frames then
					en.running_frame = 1
				else
					en.running_frame = en.running_frame + 1
				end
			end
			if en.key_pressed["left"] > 0 and en.facing == -1 then
				en.accel_x = en.running_speed_x * en.facing
				en.next_frame = en.running_frames[en.running_frame]
			elseif en.key_pressed["right"] > 0 and en.facing == 1 then
				en.accel_x = en.running_speed_x * en.facing
				en.next_frame = en.running_frames[en.running_frame]
			else
				en.next_frame = en.running_stop
			end
			if en.key_pressed["up"] > 0 then
				en.accel_z = en.running_speed_z * -1
			elseif en.key_pressed["down"] > 0 then
				en.accel_z = en.running_speed_z * 1
			end
		end
	end
end