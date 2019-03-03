local state = { variables = {} } -- | 4 | -- Прыжок вверх
-- Персонаж приобретает положительную скорость и движется вверх, постепенно скорость уменьшается. При достижении нулевой скорости, персонаж переходит в кадры "стойки в воздухе" и начинает падение.
-- Если стартовая скорость выше определенного значения, вызывается эффект "jerk_up".
---------------------------------------------------------------------
function state:Processing(object,s)
	object.gravity = true
	if object.first_tick then
		object:addMotion_X(get.notNil(s.dvx, 0) * object.facing)
		object:addMotion_Y(get.notNil(s.dvy, 0))
		if object:pressed("up") then
			object:addMotion_Z(-get.notNil(s.dvz, 0))
		elseif object:pressed("down") then
			object:addMotion_Z(get.notNil(s.dvz, 0))
		end
	end
	if object.vel_y > 0 then
		if object.wait == 0 then
			object:setFrame(object.frame.number)
		end
	else
		object:setFrame("air_standing")
	end

	--[[if object.vel_y > 0 then
		if object.vel_y > 10 and object.old_vel_y == 0 then
			local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y, object.z + 1, object.facing, 0, object.owner)
			if effect ~= nil then effect:setFrame(effect.head.frames["jerk_up"]) end
		end
		if object.wait == 0 and object.frame.next == 0 then
			object:setFrame(object.frame.number)
		end
	else
		if s.down ~= nil then object:setFrame(s.down)
		else object:setFrame("air_standing") end
	end]]
end
return state