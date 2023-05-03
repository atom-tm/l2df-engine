--- Jumping
return function (obj, data, params)
	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	if not data.ground then
		if data.jspeedx then
			data.dvx = data.jspeedx
			data.jspeedx = nil
		end
		if data.jspeedz then
			data.dvz = data.jspeedz
			data.jspeedz = nil
		end
		local left = control.pressed('left')
		local right = control.pressed('right')
		data.facing = left and -1 or right and 1 or data.facing
	end
	if data.frame.id == 211 and not data.isjumped then
		data.dvy = attr.data().jump_height
		data.isjumped = true
	end
	if data.frame.id < 212 then return end
	if data.ground then
		frames.set('crouch')
	else
		data.next = data.frame.id
	end
end