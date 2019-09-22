local state = { variables = {} } -- | 620 | -- Эффекты
-- 
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.first_tick then
		local effect = battle.entities.spawnObject(battle.map.head.effects, object.x + object.vel_x, object.y, object.z + 1, object.facing, 0, object.owner)
		if effect ~= nil then
			effect:setFrame(effect.head.frames["slammed"])
		end
	end
end

return state