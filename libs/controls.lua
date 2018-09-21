players = {
	player1 = 1,
	player2 = 2
}


key_pressed = {
	player1 = {
		up = 0,
		down = 0,
		left = 0,
		right = 0,
		attack = 0,
		jump = 0,
		defend = 0
	},
	player2 = {
		up = 0,
		down = 0,
		left = 0,
		right = 0,
		attack = 0,
		jump = 0,
		defend = 0
	}
}

control_settings = {
	player1 = {
		up = "w",
		down = "s",
		left = "a",
		right = "d",
		attack = "f",
		jump = "g",
		defend = "h"
	},
	player2 = {
		up = "o",
		down = "l",
		left = "k",
		right = ";",
		attack = "p",
		jump = "[",
		defend = "]"
	}
}


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
					en.key_timer[key] = 5
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



end