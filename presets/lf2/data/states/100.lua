--- Special Landing
return function (obj, data)
	local frames = obj.C.frames
	if not frames then
		return
	end

	if data.ground then
		if data._lf2_state100_airborne then
			data._lf2_state100_airborne = nil
			frames.set(94)
		end
	else
		data._lf2_state100_airborne = true
	end
end
