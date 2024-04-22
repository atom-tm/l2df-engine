--- Attacks
return function (obj, data)
	local frames = obj.C.frames
	if frames and data.frame.keyword == 'jump_attack' and data.isjumped and data.ground then
		frames.set('crouch')
	end
end