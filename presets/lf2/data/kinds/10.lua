--- Sonata of Death.
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
		e2.data.dvy = math.min(e2.data.dvy or 0, -4)
		e2.data.vy = 0
	end
	return normalHit.queue(e1, e2, {
		owner = itr.owner,
		syncid = itr.syncid,
		syncindex = itr.syncindex,
		kind = itr.kind,
		vrest = itr.vrest or 1,
		dvx = itr.dvx or 0,
		dvy = itr.dvy or -4,
		dvz = itr.dvz,
		fall = itr.fall or 20,
		bdefend = itr.bdefend or 0,
		injury = itr.injury or 1,
		effect = itr.effect,
	})
end
