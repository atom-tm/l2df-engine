--- Reflective shield.
local normalHit = require 'data.kinds.normal_hit'
local relationship = require 'data.scripts.relationship'

return function (e1, e2, itr, bdy)
	if not (e1 and e2 and itr and bdy and itr.owner == e1 and bdy.owner == e2) then
		return false
	end
	if e2.data._lf2_type == 3 then
		local facing = e1.data.facing or -(e2.data.facing or 1)
		local speed = math.abs(e2.data._lf2_dvx or e2.data.dvx or itr.dvx or 10)
		e2.data.ownerid = relationship.ownerid(e1.data)
		e2.data.team = e1.data.team
		e2.data.facing = facing
		e2.data._lf2_dvx = speed * facing
		e2.data.dvx = speed * facing
		return true
	end
	return normalHit.queue(e1, e2, itr)
end
