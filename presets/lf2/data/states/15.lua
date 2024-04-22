--- Misc state. Used for weapon throw, dash attack, running stop and other frames.
return function (obj, data)
	local frames = obj.C.frames
	local control = obj.C.controller
	local attr = obj.C.attr
	if not (frames and control and attr) then return end
	local up = control.pressed('up')
	local down = control.pressed('down')
	local left = control.pressed('left')
	local right = control.pressed('right')
	if data.frame.keyword == 'dash_attack' and data.ground and data.isdashed then
		frames.set('crouch')
	elseif
		(data.isjumped or data.flip) and data.ground and
		data.frame.keyword == 'crouch' and
		control.pressed('jump') and (data.flip or left or right)
	then
		if left or right then
			data.facing = left and -1 or 1
			data.flip = 1
		end
		local adata = attr.data()
		data.jspeedx = adata.dash_distance * (data.flip or 1)
		data.jspeedz = up ~= down and adata.dash_distancez * (up and - 1 or 1)
		frames.set(data.flip == 1 and 'dash' or 214) -- backward dash
		data.isjumped = nil
		data.flip = nil
	end
end