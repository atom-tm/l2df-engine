local state = { variables = {} } -- | 12 | -- Атака
-- 
---------------------------------------------------------------------
function state:Processing(object,s)
	if s.time then
		local entities = battle.entities.list
		for i in pairs(entities) do
			if object.dynamic_id ~= entities[i].dynamic_id then 
				entities[i]:timeSlow(object.frame.wait, 60)
			end
		end
		local effects = battle.entities.effects
		for j in pairs(effects) do
			effects[j]:timeSlow(object.frame.wait, 60)
		end
	end
end

return state