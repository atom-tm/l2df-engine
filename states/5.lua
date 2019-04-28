local state = { variables = {} } -- | 5 | -- Стойка в воздухе
--Персонаж находится в воздухе в состоянии свободного падения. При достижении земли, переходит в кадры "приземления", обнуляя скорость по оси Y.
-- A	Атака в воздухе
-- S↓*	Рывок вниз
---------------------------------------------------------------------
function state:Processing(object,s)
	object.gravity = true
	if object.grounded then
		if object.old_vel_x * object.facing > 5 and object.old_vel_y < -10 then
			local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y, object.z + 1, object.facing * -1, 0, object.owner)
			if effect ~= nil then
				effect:setFrame(effect.head.frames["speedup"])
				effect:setMotion_X(object.vel_x)
			end
		elseif object.old_vel_x * object.facing < -5 and object.old_vel_y < -10 then
			local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y, object.z + 1, object.facing, 0, object.owner)
			if effect ~= nil then
				effect:setFrame(effect.head.frames["speedup"])
				effect:setMotion_X(object.vel_x)
			end
		elseif object.old_vel_y < -10 then
			local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y, object.z + 1, object.facing, 0, object.owner)
			if effect ~= nil then
				effect:setFrame(effect.head.frames["landing"])
				effect:setMotion_X(object.vel_x)
			end
		end
		object:setFrame("landing")
	else
		if object:timer("special1") and object:pressed("down") then object:setFrame("shunshin_down") end
		if object.wait == 0 and object.frame.next == 0 then
			object:setFrame(object.frame.number)
		end
	end
end
return state