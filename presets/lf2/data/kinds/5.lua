--- Weapon strength.
local normalHit = require 'data.kinds.normal_hit'
local frame = require 'data.scripts.frame'

local function selectedStrength(data)
	local attack = frame.number(data and data.wpoint and data.wpoint.attacking, 0)
	local strengths = data and data.weapon_strengthes
	if attack <= 0 or type(strengths) ~= 'table' then
		return nil
	end
	for i = 1, #strengths do
		if frame.number(strengths[i][1], 0) == attack then
			return strengths[i]
		end
	end
	return nil
end

return function (e1, e2, itr, bdy)
	if not (e1 and e2 and itr and bdy and itr.owner == e1 and bdy.owner == e2) then
		return false
	end
	local strength = selectedStrength(e1.data)
	if strength then
		itr = {
			owner = itr.owner,
			syncid = itr.syncid,
			syncindex = itr.syncindex,
			kind = itr.kind,
			arest = strength.arest or itr.arest,
			vrest = strength.vrest or itr.vrest,
			dvx = strength.dvx or itr.dvx,
			dvy = strength.dvy or itr.dvy,
			dvz = strength.dvz or itr.dvz,
			fall = strength.fall or itr.fall,
			bdefend = strength.bdefend or itr.bdefend,
			injury = strength.injury or itr.injury,
			effect = strength.effect or itr.effect,
		}
	elseif itr.injury == 789 then
		itr = {
			owner = itr.owner,
			syncid = itr.syncid,
			syncindex = itr.syncindex,
			kind = itr.kind,
			arest = itr.arest,
			vrest = itr.vrest or 10,
			dvx = itr.dvx or 8,
			dvy = itr.dvy,
			dvz = itr.dvz,
			fall = itr.fall or 20,
			bdefend = itr.bdefend or 16,
			injury = 0,
			effect = itr.effect,
		}
	end
	return normalHit.queue(e1, e2, itr)
end
