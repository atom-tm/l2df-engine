local state = { variables = {} } -- | 100 | -- Визуальные эффекты
-- Создает нужный эффект, из списка эффектов карты, при определенных условиях
-- s.effect - тип создаваемого эффекта
-- s.vel_x - (+) условие, если скорость больше указанного значения
-- s.vel_x - (-) условие, если скорость меньше указанного значения
---------------------------------------------------------------------
function state:Processing(object,s)
	if s.effect ~= nil and object.first_tick then
	local checker = true

		if s.vel_x ~= nil and type(s.vel_x) == "number" and checker then
			if s.vel_x > 0 then
				if (object.vel_x * object.facing) < s.vel_x then checker = false end
			elseif s.vel_x < 0 then
				if (object.vel_x * object.facing) > (s.vel_x * -1) then checker = false end
			end
		end

		if checker then
			local x = object.x + (get.notNil(s.x, 0) * object.facing)
			local y = object.y + get.notNil(s.y, 0)
			local z = object.z + get.notNil(s.z, 1)
			local facing = object.facing * get.notNil(s.facing, 1)
			local effect = battle.entities.spawnObject(battle.map.head.effects, x, y, z, facing, 0, object.owner)
			if effect ~= nil then
				effect:setFrame(effect.head.frames[s.effect])
				if s.dvx_inheritance then effect:setMotion_X(object.vel_x) end
				effect:addMotion_X(get.notNil(s.dvx,0) * object.facing)
			end
		end
	end
end

return state