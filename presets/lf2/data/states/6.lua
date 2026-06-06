--- Rowing
-- Rolling / Flipping state
local frame = require 'data.scripts.frame'
local normalHit = require 'data.kinds.normal_hit'

return function (obj, data)
	local frames = obj.C.frames
	if normalHit.processReaction(obj) then
		return
	end
	if data.frame.id == 105 and frame.entered(data, 'rowing_slide') then
		data._lf2_slide = 6
		data._lf2_slide_subframe = 1
	end
	-- TODO: should be data.air instead
	if frames and (data.flip or data.isjumped or data.isdashed) and data.ground then
		frames.set('crouch')
	end
end
