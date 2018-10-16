players = {
	nil,
	nil
} -- массив в котором будут храниться ссылки на привязанных к игрокам персонажей

players_flags = {
	true,
	true
} -- массив в котором будут лежать флаги, отвечающие за то, какие игроки выбраны

key_pressed = {
	{
		up = 0,
		down = 0,
		left = 0,
		right = 0,
		attack = 0,
		jump = 0,
		defend = 0,
		jutsu = 0
	},
	{
		up = 0,
		down = 0,
		left = 0,
		right = 0,
		attack = 0,
		jump = 0,
		defend = 0,
		jutsu = 0
	}
} -- если была нажата какая-то из кнопок управления

control_settings = {
	{
		up = "w",
		down = "s",
		left = "a",
		right = "d",
		attack = "f",
		jump = "g",
		defend = "h",
		jutsu = "j"
	},
	{
		up = "o",
		down = "l",
		left = "k",
		right = ";",
		attack = "p",
		jump = "[",
		defend = "]",
		jutsu = "\\"
	}
} -- тут лежат все настройки управления

key_timer = 13
key_double_timer_reverse = -15
key_double_timer = 26

function ControlCheck()
	for player, en_id in pairs(players) do
		if en_id ~= nil then
			local en = entity_list[en_id]
			for key, val in pairs(control_settings[player]) do
				if love.keyboard.isDown(val) then
					en.key_pressed[key] = 1
				else
					en.key_pressed[key] = 0
				end
			end
			for key, val in pairs(key_pressed[player]) do
				if (val == 1) and (en.key_timer[key] == 0) then
					en.key_timer[key] = key_timer
					if en.double_key_timer[key] == 0 then
						en.double_key_timer[key] = key_double_timer_reverse
					elseif en.double_key_timer[key] < 0 then
						en.double_key_timer[key] = key_double_timer
					end
				elseif en.key_timer[key] > 0 then
					en.key_timer[key] = en.key_timer[key] - 1
				end

					if en.double_key_timer[key] > 0 then
						en.double_key_timer[key] = en.double_key_timer[key] - 1
					elseif en.double_key_timer[key] < 0 then
						en.double_key_timer[key] = en.double_key_timer[key] + 1
					end
			end

			for key, val in pairs(key_pressed[player]) do
				if (val == 1) and (en.double_key_timer[key] == 0) then
					
				elseif (val == 1) and (en.double_key_timer[key] < 0) then
				elseif en.key_timer[key] > 0 then
					en.key_timer[key] = en.key_timer[key] - 1
				end
			end


			for key, val in pairs(control_settings[player]) do
				key_pressed[player][key] = 0
			end
		end
	end
end


function HitCheck(en_id)
	local en = entity_list[en_id]
	if en ~= nil then
		local frame = GetFrame(en)

		local timer = 40

		if en.hit_code ~= 0 then
			en.hit_timer = en.hit_timer - 1
			if en.hit_timer == 0 then
				en.hit_code = 0
			end
		end

		if en.key_timer["defend"] >= key_timer then
			en.hit_code = 1
			en.hit_timer = timer
		end
		if en.key_timer["attack"] >= key_timer then
			en.hit_code = en.hit_code .. 2
			en.hit_timer = timer
		end
		if en.key_timer["jump"] >= key_timer then
			en.hit_code = en.hit_code .. 3
			en.hit_timer = timer
		end
		if en.key_timer["jutsu"] >= key_timer then
			en.hit_code = en.hit_code .. 4
			en.hit_timer = timer
		end
		if en.key_timer["up"] >= key_timer then
			en.hit_code = en.hit_code .. 5
			en.hit_timer = timer
		end
		if en.key_timer["down"] >= key_timer then
			en.hit_code = en.hit_code .. 6
			en.hit_timer = timer
		end
		if en.key_timer["left"] >= key_timer then
			en.hit_code = en.hit_code .. 7
			en.hit_timer = timer
		end
		if en.key_timer["right"] >= key_timer then
			en.hit_code = en.hit_code .. 7
			en.hit_timer = timer
		end

		local f_num = 0
		if en.hit_code == "152" then
			f_num = frame.hit_Ua
		elseif en.hit_code == "153" then
			f_num = frame.hit_Uj
		elseif en.hit_code == "162" then
			f_num = frame.hit_Da
		elseif en.hit_code == "163" then
			f_num = frame.hit_Dj
		elseif en.hit_code == "172" then
			f_num = frame.hit_Fa
		elseif en.hit_code == "173" then
			f_num = frame.hit_Fj
		elseif en.key_timer["attack"] > 0 then
			f_num = frame.hit_a
		elseif en.key_timer["jump"] > 0 then
			f_num = frame.hit_j
		elseif en.key_timer["defend"] > 0 then
			f_num = frame.hit_d
		end


		
		if f_num ~= 0 then
			SetFrame(en, f_num)
			en.hit_code = 0

			for key in pairs(en.key_timer) do
				en.key_timer[key] = 0
			end

		end


	end
end