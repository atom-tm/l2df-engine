local state = { variables = {} } -- | 2 | -- Бег
-- Персонаж передвигается бегом, последовательно изменяя спрайт бега, согласно установленному счетчику. При окончании удержания клавиш "продолжения бега" персонаж переходит в кадры "остановки бега".
-- 	⇄*	Продолжение бега
-- 	A	Сильная атака
-- 	J	Прыжок вперед
-- 	D	Рывок вперед
-- Если скорость бега превышает 25, при начале бега появляется визуальный эффект "speedup".
---------------------------------------------------------------------
function state:Processing(object,s)
	object.x_friction = false
	if s.speed_x ~= nil then
		if object:pressed("left") and object.facing == -1 then
			if object.vel_x > -s.speed_x then object:addMotion_X(-s.speed_x * 0.2)
			else object:setMotion_X(-s.speed_x) end
		elseif object:pressed("right") and object.facing == 1 then
			if object.vel_x < s.speed_x then object:addMotion_X(s.speed_x * 0.2)
			else object:setMotion_X(s.speed_x) end
		else
			object:setFrame("stop_running")
		end
	end

	if s.speed_z ~= nil then
		if object:pressed("up") then
			object:setMotion_Z(-s.speed_z)
			object:setMotion_X(object.vel_x * 0.85)
		end
		if object:pressed("down") then
			object:setMotion_Z(s.speed_z)
			object:setMotion_X(object.vel_x * 0.85)
		end
	end

	if object.first_tick and s.speed_x ~= nil then
		local first_frame = true
		for i = 1, #object.previous_frame.states do
			if object.previous_frame.states[i].number == "2" then
				first_frame = false
			end
		end
		if s.speed_x > 25 and first_frame then
			local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y, object.z + 1, object.facing, 0, object.owner)
			if effect ~= nil then
				effect:setFrame(effect.head.frames["speedup"])
			end
		end
	end

	if object:timer("attack") then object:setFrame("strong_attack") end
	if object:timer("jump") then object:setFrame("jump_forward") end
	if object:pressed("special1") and object.block_timer == 0 then object:setFrame("shunshin_forward") end


	if object:pressed("left") or object:pressed("right") then
		if object.first_tick then
			object.running_frame = object.running_frame + 1
			if object.running_frame > #object.head.frames["running"] then
				object.running_frame = 1
			end
		end
		if object.wait == 0 then
			object:setFrame("running",object.running_frame)
		end
	end

end

return state