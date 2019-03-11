local state = { variables = {} } -- | 4 | -- Прыжок вверх
-- Персонаж приобретает положительную скорость и движется вверх, постепенно скорость уменьшается. При достижении нулевой скорости, персонаж переходит в кадры "стойки в воздухе" и начинает падение.
-- Если стартовая скорость выше определенного значения, вызывается эффект "jerk_up".
---------------------------------------------------------------------
function state:Processing(object,s)
	object.gravity = true
	if object.first_tick and not get.stateExist(object.previous_frame,4) then

		if s.dvx ~= nil then
			if s.dvx > 0 then
				if s.dvx > object.vel_x * object.facing then
					object:setMotion_X(s.dvx * object.facing)
				end
			elseif s.dvx < 0 then
				if s.dvx < object.vel_x * object.facing then
					object:setMotion_X(s.dvx * object.facing)
				end
			else
				object:setMotion_X(s.dvx * object.facing)
			end
		end
		if s.dvy ~= nil then
			object:setMotion_Y(s.dvy)
		end
		if s.dvz ~= nil then		
			if object:pressed("up") then
				object:setMotion_Z(-s.dvz)
			elseif object:pressed("down") then
				object:setMotion_Z(s.dvz)
			end
		end

		if object.vel_x * object.facing > 5 and object.vel_y > 10 then
			local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y - object.frame.dy, object.z + 1, object.facing, 0, object.owner)
			if effect ~= nil then
				effect:setFrame(effect.head.frames["speedup"])
			end
		elseif object.vel_x * object.facing < -5 and object.vel_y > 10 then
			local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y - object.frame.dy, object.z + 1, object.facing * -1, 0, object.owner)
			if effect ~= nil then
				effect:setFrame(effect.head.frames["speedup"])
			end
		elseif object.vel_y > 10 then
			local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y - object.frame.dy, object.z + 1, object.facing, 0, object.owner)
			if effect ~= nil then
				effect:setFrame(effect.head.frames["landing"])
			end
		end
	end
	if object.vel_y > 0 then
		if object.wait == 0 and object.frame.next == 0 then
			object:setFrame(object.frame.number)
		end
	else
		object:setFrame("air_standing")
	end
end
return state