--- Whirlwind freeze.
local normalHit = require 'data.kinds.normal_hit'
local relationship = require 'data.scripts.relationship'

return function (e1, e2, itr, bdy)
	if not (e1 and e2 and itr and bdy and itr.owner == e1 and bdy.owner == e2) then
		return false
	end
	if relationship.isFriendly(e1, e2) then
		return false
	end
	if e2.data._lf2_type == 0 then
		if e2.C and e2.C.frames then
			e2.C.frames.set(200)
		end
		e2.data._lf2_ice_airborne = not e2.data.ground or nil
		return normalHit.queue(e1, e2, {
			owner = itr.owner,
			syncid = itr.syncid,
			syncindex = itr.syncindex,
			kind = itr.kind,
			vrest = itr.vrest,
			dvx = itr.dvx,
			dvy = itr.dvy,
			dvz = itr.dvz,
			fall = itr.fall,
			bdefend = itr.bdefend,
			injury = itr.injury,
			effect = 30,
		})
	end
	if e2.data._lf2_type == 1 or e2.data._lf2_type == 2 or e2.data._lf2_type == 6 then
		e2.data.dvy = itr.dvy or -6
		return true
	end
end
