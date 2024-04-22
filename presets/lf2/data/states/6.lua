--- Rowing
-- Rolling / Flipping state
return function (obj, data)
	local frames = obj.C.frames
	-- TODO: should be data.air instead
	if frames and (data.flip or data.isjumped or data.isdashed) and data.ground then
		frames.set('crouch')
	end
end