local state = { variables = {} } -- | 7 | -- Шуншин
-- Персонаж совершает резкий рывок вперед с указанной силой
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.first_tick and not helper.stateExist(object.previous_frame,7) then
		if s.dvx ~= nil then
			object:addMotion_X(s.dvx * object.facing);
			if object.vel_x * object.facing > 15 then
				local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y, object.z + 1, object.facing, 0, object.owner)
				if effect ~= nil then effect:setFrame(effect.head.frames["speedup"]) end
			elseif object.vel_x * object.facing < -15 then
				local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y, object.z + 1, object.facing * -1, 0, object.owner)
				if effect ~= nil then effect:setFrame(effect.head.frames["speedup"]) end
			end
		end
		if s.dvz ~= nil then
			if object:pressed("up") then
				object:setMotion_Z(-s.dvz)
			end
			if object:pressed("down") then
				object:setMotion_Z(s.dvz)
			end
		end
	end
	if object:timer("attack") and object.vel_x * object.facing > 0 then
		object:setFrame("strong_attack")
	end
	if object.wait == 0 and object.frame.next == 0 then
		object:setFrame("shunshin_stop")
	end
end
---------------------------------------------------------------------
return state