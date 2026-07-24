--- Whirlwind wind. Pulls targets inward and applies normal hit tags.
local normalHit = require 'data.kinds.normal_hit'
local relationship = require 'data.scripts.relationship'

return function (e1, e2, itr, bdy)
	if not (e1 and e2 and itr and bdy and itr.owner == e1 and bdy.owner == e2) then
		return false
	end
	if relationship.isFriendly(e1, e2) then
		return false
	end
	local dx = (e1.data.x or 0) - (e2.data.x or 0)
	e2.data.dvx = (dx < 0 and -1 or 1) * math.abs(itr.dvx or 6)
	if itr.dvy then
		e2.data.dvy = itr.dvy
	end
	return normalHit.queue(e1, e2, itr)
end
