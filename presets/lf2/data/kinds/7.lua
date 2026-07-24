--- Pick Weapon 2
local object = require 'data.scripts.object'

return function (e1, e2, itr, bdy)
	if not (e1 and e2 and itr and bdy and itr.owner == e1 and bdy.owner == e2) then
		return false
	end
	if e1.data._lf2_weapon then
		return false
	end
	return object.pickupWeapon(e1, e2, { light_only = true, no_animation = true })
end
