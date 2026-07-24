--- Caught
local catch = require 'data.kinds.catch'
local frame = require 'data.scripts.frame'
local object = require 'data.scripts.object'

return function (obj, data)
	if catch.processReaction(obj) then
		return
	end
	if data._lf2_weapon and frame.entered(data, 'caught_drop_weapon') then
		object.dropWeapon(obj)
	end
end
