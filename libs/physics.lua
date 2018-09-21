function Gravity(en_id) -- отвечает за гравитацию, иннерцию и скорость персонажа по всем осям. функция не выполняет перемещение, а лишь высчитывает поведение скоростей исходя из всех факторов.
-------------------------------------
	local en = entity_list[en_id]

	if en.physic then
		if en.y >= 350 + en.vel_y then
			en.y = 350
			en.in_air = false
		end

		if not (en.in_air) then 
			if en.vel_y > 0 then en.vel_y = 0 end
			en.vel_x = en.vel_x * 0.8
		else
			en.vel_y = en.vel_y + en.weight * delta_time
			en.vel_x = en.vel_x * 0.99
		end
	end
end


function Motion(en, dt)
	en.y = en.y + en.vel_y
	en.x = en.x + en.vel_x
	w, h, k = love.window.getMode()
	
	if (en.x > w) or (en.x < 0) then
		en.vel_x = en.vel_x * -1
	end

	if (en.y > h) or (en.y < 0) then
		en.vel_y = en.vel_y * -1
	end

end