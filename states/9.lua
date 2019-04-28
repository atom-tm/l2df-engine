local state = { variables = {} } -- | 9 | -- Защита
-- Устанавливает объекту дополнительную защиту
--		block 		Количество добавляемой защиты
---------------------------------------------------------------------
function state:Update(object)
	if state.variables.block_status then
		state.variables.block_status = false
	else
		object.block = 0
	end
end
---------------------------------------------------------------------
function state:Processing(object,s)
	if object:pressed("defend") then
		if object.block <= 0 then
			object.block = s.block
		end
		state.variables.block_status = true
		object.block_timer = get.notNil(s.timer,0)
		if object.wait == 0 then
			object.wait = object.wait + 1
		end
	end
	if object.vel_x * object.facing < -5 then
		local effect = battle.entities.spawnObject(battle.map.head.effects, object.x + math.random(5,15), object.y, object.z + math.random(1,3), object.facing, 0, object.owner)
		if effect ~= nil then
			effect:setFrame("fricted")
		end
	end
end

return state