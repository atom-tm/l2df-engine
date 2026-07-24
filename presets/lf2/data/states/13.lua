--- Ice
local core = assert(l2df, 'L2DF is not available')
local normalHit = require 'data.kinds.normal_hit'

return function (obj, data)
	if normalHit.processReaction(obj) then
		return
	end

	if not data.ground then
		data._lf2_ice_airborne = true
		data._lf2_ice_landing_speed = math.max(data._lf2_ice_landing_speed or 0, math.abs(data.vy or data.dvy or 0))
		return
	end
	if not data._lf2_ice_airborne then
		return
	end

	data._lf2_ice_airborne = nil
	local speed = data._lf2_ice_landing_speed or 0
	data._lf2_ice_landing_speed = nil
	if speed < core:convert(3) then
		return
	end
	local attr = obj.C.attr
	local adata = attr and attr.data()
	if adata then
		adata.hp = math.max(0, adata.hp - 10)
		if adata.hp <= 0 then
			adata.maxhp = 0
		elseif adata.hp > adata.maxhp then
			adata.hp = adata.maxhp
		end
	end
end
