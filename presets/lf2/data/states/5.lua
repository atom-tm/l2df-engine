--- Dash
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
	end
	if data.frame.id == 213 then
		if not data.isdashed then
			data.dvy = attr.data().dash_height
			data.isdashed = true
		end
		return
	end
	if data.ground then
		frames.set('crouch')
	else
		data.next = data.frame.id
	end
end