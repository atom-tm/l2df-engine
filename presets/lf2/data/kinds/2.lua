--- Pick Weapon
-- hit_XX are disabled if a character is holding a heavy weapon via itr kind 2,
-- state: 2 itself doesn't disable hit_XX.
-- For details go the section for itr kind 2.
local object = require 'data.scripts.object'

return function (e1, e2, itr, bdy)
	if not (e1 and e2 and itr and bdy and itr.owner == e1 and bdy.owner == e2) then
		return false
	end
	if e1.data._lf2_weapon then
		return false
	end
	return object.pickupWeapon(e1, e2)
end
