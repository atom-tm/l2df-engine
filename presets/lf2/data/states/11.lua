--- Injured
local frame = require 'data.scripts.frame'
local normalHit = require 'data.kinds.normal_hit'
local object = require 'data.scripts.object'

return function (obj, data)
	if normalHit.processReaction(obj) then
		return
	end
	if data._lf2_weapon == 'heavy' and frame.entered(data, 'injured_drop_heavy') then
		object.dropWeapon(obj)
	end
	if frame.entered(data, 'injured_wait') then
		frame.addWait(obj, 1)
	end
end
