players = {
	player1 = nil,
	player2 = nil
} -- массив в котором будут храниться ссылки на привязанных к игрокам персонажей

players_flags = {
	player1 = false,
	player2 = true
} -- массив в котором будут лежать флаги, отвечающие за то, какие игроки выбраны

key_pressed = {
	player1 = {
		up = 0,
		down = 0,
		left = 0,
		right = 0,
		attack = 0,
		jump = 0,
		defend = 0,
		jutsu = 0
	},
	player2 = {
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
	player1 = {
		up = "w",
		down = "s",
		left = "a",
		right = "d",
		attack = "f",
		jump = "g",
		defend = "h",
		jutsu = "j"
	},
	player2 = {
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
					en.key_timer[key] = 13
					if en.double_key_timer[key] == 0 then
						en.double_key_timer[key] = -14
					elseif en.double_key_timer[key] < 0 then
						en.double_key_timer[key] = 13
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


function hit_Check(en, frame)

	if (en.double_key_timer.left > 0) and (frame.double_left ~= 0) then
		SetFrame(en, frame.double_left)
		en.facing = -1
	end

	if (en.key_pressed.left == 1) and (frame.hold_left ~= 0) then
		en.next_frame = frame.hold_left
	end


end