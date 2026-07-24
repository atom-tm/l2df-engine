--- Heal ball.
local object = require 'data.scripts.object'
local frame = require 'data.scripts.frame'

return function (e1, e2, itr, bdy)
	if not (e1 and e2 and itr and bdy and itr.owner == e1 and bdy.owner == e2) then
		return false
	end
	if e2.data._lf2_type ~= 0 then
		return false
	end
	local attr = e2.C and e2.C.attr
	local adata = attr and attr.data()
	if not adata then
		return false
	end
	adata.hp = math.min(adata.maxhp, (adata.hp or 0) + frame.number(itr.injury, 0))
	local target = frame.number(itr.dvx, nil)
	if target and e1.C and e1.C.frames then
		e1.C.frames.set(target)
	else
		object.projectileHit(e1)
	end
	return true
end
