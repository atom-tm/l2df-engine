--- Sonata helper. Suspends characters without applying direct damage.
local relationship = require 'data.scripts.relationship'

return function (e1, e2, itr, bdy)
	if not (e1 and e2 and itr and bdy and itr.owner == e1 and bdy.owner == e2) then
		return false
	end
	if relationship.isFriendly(e1, e2) or e2.data._lf2_type ~= 0 then
		return false
	end
	e2.data.dvy = math.min(e2.data.dvy or 0, -3)
	e2.data.vy = 0
	return true
end
