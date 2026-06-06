--- Injured 2 (Dance of Pain)
local frame = require 'data.scripts.frame'
local normalHit = require 'data.kinds.normal_hit'

return function (obj, data)
	-- TODO: add catch
	if normalHit.processReaction(obj) then
		data.stunned = true
		return
	end
	if frame.entered(data, 'injured_wait') then
		frame.addWait(obj, 1)
	end
	data.stunned = true
end
