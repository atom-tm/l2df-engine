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
			if en.key_timer["jump"] > 0 and en.jump_frame ~= 0 then
				SetFrame(en, en.jump_frame)
			end
			if en.key_timer["attack"] > 0 then
				if #en.attack_frames > 0 then
					SetFrame(en, en.attack_frames[math.random(1, #en.attack_frames)])
				end
			end
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
				en.taccel_x = en.walking_speed_x * en.facing
				en.next_frame = en.walking_frames[en.walking_frame]
			elseif en.key_pressed["right"] > 0 then
				en.facing = 1
				en.taccel_x = en.walking_speed_x * en.facing
				en.next_frame = en.walking_frames[en.walking_frame]
			end
			if en.key_pressed["up"] > 0 then
				en.taccel_z = en.walking_speed_z * -1
				en.next_frame = en.walking_frames[en.walking_frame]
			elseif en.key_pressed["down"] > 0 then
				en.taccel_z = en.walking_speed_z * 1
				en.next_frame = en.walking_frames[en.walking_frame]
			end

			if (en.double_key_timer["left"] == 25 and en.facing == -1) or (en.double_key_timer["right"] == 25 and en.facing == 1) then
				SetFrame(en, en.running_frames[en.running_frame])
			end -- если дважды нажаты клавиши управления, переход в кадры бега
			
			if en.key_timer["jump"] > 0 and en.jump_frame ~= 0 then
				SetFrame(en, en.jump_frame)
			end

			if en.key_timer["attack"] > 0 then
				if #en.attack_frames > 0 then
					SetFrame(en, en.attack_frames[math.random(1, #en.attack_frames)])
				end
			end
		end

		if state.num == "3" then -- бег
			if en.wait <= 0 then
				if en.running_frame == #en.running_frames then
					en.running_frame = 1
				else
					en.running_frame = en.running_frame + 1
				end
			end
			if (en.key_pressed["left"] > 0 or en.double_key_timer["left"] > 0) and en.facing == -1 then
				en.accel_x = en.running_speed_x * en.facing
				en.next_frame = en.running_frames[en.running_frame]
			elseif (en.key_pressed["right"] > 0 or en.double_key_timer["right"] > 0) and en.facing == 1 then
				en.accel_x = en.running_speed_x * en.facing
				en.next_frame = en.running_frames[en.running_frame]
			else
				en.next_frame = en.running_stop
			end

			if en.key_pressed["up"] > 0 then
				en.accel_z = en.running_speed_z * -1
				en.accel_x = en.running_speed_x * 0.8 * en.facing
			elseif en.key_pressed["down"] > 0 then
				en.accel_z = en.running_speed_z * 1
				en.accel_x = en.running_speed_x * 0.8 * en.facing
			end	

			if en.key_timer["jump"] > 0 and en.dash_frame ~= 0 then
				SetFrame(en, en.dash_frame)
			end

			if en.key_timer["attack"] > 0 then
				SetFrame(en, en.run_attack_frame)
			end
		end

		if state.num == "4" then
			if not (en.y > 0 and en.on_platform == false) then
				en.accel_y = en.jump_height
				if en.key_pressed["right"] > 0 or en.key_pressed["left"] > 0 then
					en.taccel_x = en.jump_width * en.facing
				end
				if en.key_pressed["up"] > 0 then
					en.taccel_z = en.jump_widthz * -1
				elseif en.key_pressed["down"] > 0 then
					en.taccel_z = en.jump_widthz * 1
				end
			elseif en.taccel_y < 0 then
				SetFrame(en, en.air_frame)
			elseif en.taccel_y >= 0 and en.next_frame ~= 0 and en.next_frame ~= 999 then
				en.next_frame = en.frame
			end
		end

		if state.num == "5" then
			if not (en.y > 0 and en.on_platform == false) then
				SetFrame(en, en.landing_frame)
			end
		end

		if state.num == "6" then
			if not (en.y > 0 and en.on_platform == false) then
				en.accel_y = en.dash_height
				en.taccel_x = en.taccel_x + en.dash_width * en.facing
				if en.key_pressed["up"] > 0 then
					en.taccel_z = en.dash_widthz * -1
				elseif en.key_pressed["down"] > 0 then
					en.taccel_z = en.dash_widthz * 1
				end
			elseif en.taccel_y < 0 then
				SetFrame(en, en.air_frame)
			elseif en.taccel_y >= 0 and en.next_frame ~= 0 and en.next_frame ~= 999 then
				en.next_frame = en.frame
			end
		end





		if state.num == "10" then
			if en.key_pressed["right"] > 0 then
				en.facing = 1
			elseif en.key_pressed["left"] > 0 then
				en.facing = -1
			end
		end

		if state.num == "550" then
			if state.x == true then
				en.accel_x = 0
				en.taccel_x = 0
				en.speed_x = 0
			end
			if state.y == true then
				en.accel_y = 0
				en.taccel_y = 0
				en.speed_y = 0
			end
			if state.z == true then
				en.accel_z = 0
				en.taccel_z = 0
				en.speed_z = 0
			end
		end
	end
end