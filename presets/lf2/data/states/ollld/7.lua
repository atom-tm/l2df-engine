local state = { variables = {} } -- | 7 | -- Падение
-- Поворот объекта влево\\вправо при нажатии соответствующих клавиш
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.vel_y > 0 then
		if object.next_frame == 0 and object.wait == 0 then
			if s.up ~= nil then object:setFrame(s.up)
			else object:setFrame(object.frame.number) end
		end
	else
		if not object.grounded then
			if object.next_frame == 0 and object.wait == 0 then
				if s.down ~= nil then object:setFrame(s.down)
				else object:setFrame(object.frame.number) end
			end
		else
			if s.grounded ~= nil then object:setFrame(s.grounded)
			else object:setFrame("lying") end
			if object.old_vel_y < -15 then
				local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y, object.z + 1, object.facing, 0, object.owner)
				if effect ~= nil then
					effect:setFrame(effect.head.frames["slammed"])
					effect:setMotion_X(object.vel_x)
				end
			elseif object.old_vel_y < -5 then
				local effect = battle.entities.spawnObject(battle.map.head.effects, object.x, object.y, object.z + 1, object.facing, 0, object.owner)
				if effect ~= nil then
					effect:setFrame(effect.head.frames["falling"])
					effect:setMotion_X(object.vel_x)
				end
			end
		end
	end
	object.lying = true
end
---------------------------------------------------------------------
return state