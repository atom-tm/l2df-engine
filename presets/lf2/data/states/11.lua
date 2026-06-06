--- Injured
local frame = require 'data.scripts.frame'
local normalHit = require 'data.kinds.normal_hit'

return function (obj, data)
	if normalHit.processReaction(obj) then
		return
	end
	-- TODO: drop heavy weapon
	if frame.entered(data, 'injured_wait') then
		frame.addWait(obj, 1)
	end
end
