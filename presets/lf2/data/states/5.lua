return function (obj, data, params)
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (frames and attr) then return end

	if data.frame.id == 213 then
		data.dvy = attr.data().dash_height
		return
	end
	if data.vy == 0 and data.globalY == 0 then
		frames.set('crouch')
	else
		data.next = data.frame.id
	end
end