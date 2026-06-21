--- Drinking
local core = assert(l2df, 'L2DF is not available')
local normalHit = require 'data.kinds.normal_hit'

local tick = 1 / core:convert(1)

return function (obj, data)
	if normalHit.processReaction(obj) then
		return
	end

	local attr = obj.C.attr
	local adata = attr and attr.data()
	if not adata then
		return
	end

	if data._lf2_weapon_id == 122 then
		adata.hp = math.min(adata.maxhp, adata.hp + tick)
		adata.mp = math.min(adata.maxmp, adata.mp + tick)
	elseif data._lf2_weapon_id == 123 then
		adata.mp = math.min(adata.maxmp, adata.mp + 2 * tick)
	end
end
