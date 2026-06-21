--- Burning
local normalHit = require 'data.kinds.normal_hit'

return function (obj, data)
	if normalHit.processReaction(obj) then
		return
	end

	local frames = obj.C.frames
	if not frames then
		return
	end

	if not data.ground or (data.dvy or 0) ~= 0 or (data.vy or 0) ~= 0 then
		data._lf2_burning_airborne = true
	end

	if data.ground and data._lf2_burning_airborne and (data.dvy or 0) == 0 and (data.vy or 0) == 0 then
		data._lf2_burning_airborne = nil
		frames.set(185)
		return
	end

	local id = data.frame and data.frame.id
	if id and id >= 203 and id <= 206 then
		if (data.vy or 0) > 0 and id >= 205 then
			frames.set(203)
		elseif (data.vy or 0) <= 0 and id <= 204 then
			frames.set(205)
		end
	end
end
