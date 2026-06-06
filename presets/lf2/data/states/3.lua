--- Attacks
return function (obj, data)
	local frames = obj.C.frames
	if not (frames and data.ground) then
		return
	end

	local keyword = data.frame.keyword
	if keyword == 'jump_attack' and data.isjumped or keyword == 'dash_attack' and data.isdashed then
		frames.set('crouch')
	end
end
