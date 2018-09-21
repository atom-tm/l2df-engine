function Gravity(en) -- отвечает за гравитацию, иннерцию и скорость персонажа по всем осям. функция не выполняет перемещение, а лишь высчитывает поведение скоростей исходя из всех факторов.
-------------------------------------
	if en.physic then
		en.in_air = false

		for key, val in ipairs(en.collisions) do
		end

		if en.in_air then 



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