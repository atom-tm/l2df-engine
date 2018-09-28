function Gravity(en) -- отвечает за гравитацию, иннерцию и скорость персонажа по всем осям. функция не выполняет перемещение, а лишь высчитывает поведение скоростей исходя из всех факторов.
-------------------------------------

	if en.accel_x ~= 0 then
		if en.taccel_x < en.accel_x and en.accel_x > 0 then
			if(en.taccel_x < -1) then
				en.taccel_x = en.taccel_x * (0.99 - (delta_time) * 10)
			else
				en.taccel_x = en.taccel_x + delta_time * (en.accel_x)
			end
		elseif en.taccel_x > en.accel_x and en.accel_x < 0 then
			if(en.taccel_x > 1) then
				en.taccel_x = en.taccel_x * (0.99 - (delta_time) * 10)
			else
				en.taccel_x = en.taccel_x + delta_time * (en.accel_x)
			end
		end
		en.accel_x = 0
	else
		en.taccel_x = en.taccel_x * (0.99 - (delta_time) * 5)
	end

	en.vel_x = en.taccel_x + en.speed_x
	en.speed_x = 0

	if en.accel_z ~= 0 then
		if en.taccel_z < en.accel_z and en.accel_z > 0 then
			if(en.taccel_z < -1) then
				en.taccel_z = en.taccel_z * (0.99 - (delta_time) * 10)
			else
				en.taccel_z = en.taccel_z + delta_time * (en.accel_z)
			end
		elseif en.taccel_z > en.accel_z and en.accel_z < 0 then
			if(en.taccel_z > 1) then
				en.taccel_z = en.taccel_z * (0.99 - (delta_time) * 10)
			else
				en.taccel_z = en.taccel_z + delta_time * (en.accel_z)
			end
		end
		en.accel_z = 0
	else
		en.taccel_z = en.taccel_z * (0.99 - (delta_time) * 5)
	end

	en.vel_z = en.taccel_z + en.speed_z
	en.speed_z = 0

end

function Motion(en)
	en.x = en.x + en.vel_x * delta_time * 10
	en.y = en.y + en.vel_y * delta_time * 10
	en.z = en.z + en.vel_z * delta_time * 10
end

function BordersCheck(en)
	if en.y < 0 then en.y = 0 end
	if en.y > map.border_up then en.y = map.border_up end
	if en.z < 0 then en.z = 0 end
	if en.z > map.area then en.z = map.area end
	if en.x < 0 then en.x = 0 end
	if en.x > map.width then en.x = map.width end
end