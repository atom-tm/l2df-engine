function Gravity(en_id) -- отвечает за гравитацию, иннерцию и скорость персонажа по всем осям. функция не выполняет перемещение, а лишь высчитывает поведение скоростей исходя из всех факторов.
-------------------------------------
	local en = entity_list[en_id]

	local friction = map.friction
	if en.y > 0 and en.on_platform == false then friction = 0 end

	if en.physic == true then
		if en.accel_y ~= 0 then
			en.taccel_y = en.accel_y
			en.accel_y = 0
		end
		if en.y > 0 and en.on_platform == false then
			if en.taccel_y > -map.gravity and en.speed_y == 0 then
				en.taccel_y = en.taccel_y - delta_time * map.gravity
			end
		else
			if en.taccel_y < 0 then
				en.taccel_y = 0
			end
		end
	end



	if en.physic == true then -- ускорение и замедление после перемещения по оси x
		if en.accel_x ~= 0 and en.physic == true then
			if en.taccel_x < en.accel_x and en.accel_x > 0 then
				if(en.taccel_x < -1) then
					en.taccel_x = en.taccel_x * (0.99 - (delta_time) * (friction * 1.25))
				else
					en.taccel_x = en.taccel_x + delta_time * (en.accel_x) * (friction * 0.55)
				end
			elseif en.taccel_x > en.accel_x and en.accel_x < 0 then
				if(en.taccel_x > 1) then
					en.taccel_x = en.taccel_x * (0.99 - (delta_time) * (friction * 1.5))
				else
					en.taccel_x = en.taccel_x + delta_time * (en.accel_x) * (friction * 0.55)
				end
			end
			en.accel_x = 0
		else
			en.taccel_x = en.taccel_x * (0.99 - (delta_time) * (friction * 0.75))
		end
	end

	if en.physic == true then -- ускорение и замедление после перемещения по оси z
		if en.accel_z ~= 0 then
			if en.taccel_z < en.accel_z and en.accel_z > 0 then
				if(en.taccel_z < -1) then
					en.taccel_z = en.taccel_z * (0.99 - (delta_time) * (friction))
				else
					en.taccel_z = en.taccel_z + delta_time * (en.accel_z) * (friction)
				end
			elseif en.taccel_z > en.accel_z and en.accel_z < 0 then
				if(en.taccel_z > 1) then
					en.taccel_z = en.taccel_z * (0.99 - (delta_time) * (friction))
				else
					en.taccel_z = en.taccel_z + delta_time * (en.accel_z) * (friction)
				end
			end
			en.accel_z = 0
		else
			en.taccel_z = en.taccel_z * (0.99 - (delta_time) * (friction))
		end
	end

	en.vel_x = en.taccel_x + en.speed_x -- задача скорости по оси x
	en.speed_x = 0
	en.vel_y = en.taccel_y + en.speed_y
	en.speed_y = 0
	en.vel_z = en.taccel_z + en.speed_z -- задача скорости по оси x
	en.speed_z = 0

end

function Motion(en_id)
	local en = entity_list[en_id]

	if en.vel_x ~= 0 then
		en.x = en.x + en.vel_x * delta_time * 10
	end
	if en.vel_y ~= 0 then
		en.y = en.y + en.vel_y * delta_time * 10
	end
	if en.vel_z ~= 0 then
		en.z = en.z + en.vel_z * delta_time * 10
	end
end

function BordersCheck(en_id)
	local en = entity_list[en_id]
	if en ~= nil then
		if en.y < 0 then en.y = 0 end
		if en.y > map.border_up then en.y = map.border_up end
		if en.z < 0 then en.z = 0 en.accel_z = 0 en.taccel_z = 0 end
		if en.z > map.area then en.z = map.area en.accel_z = 0 en.taccel_z = 0 end
		if en.x < 0 then en.x = 0 en.accel_x = 0 en.taccel_x = 0 end
		if en.x > map.width then en.x = map.width en.accel_x = 0 en.taccel_x = 0 end
	end
end

function Accelerations(en_id)
	local en = entity_list[en_id]
	local frame = GetFrame(en)

	en.speed_x = en.speed_x + frame.dx * en.facing
	en.speed_y = en.speed_y + frame.dy
	en.speed_z = en.speed_z + frame.dz

	en.accel_x = en.accel_x + frame.dsx * en.facing
	en.accel_y = en.accel_y + frame.dsy
	en.accel_z = en.accel_z + frame.dsz

	en.taccel_x = en.taccel_x + frame.dvx * en.facing
	en.taccel_y = en.taccel_y + frame.dvy
	en.taccel_z = en.taccel_z + frame.dvz
end