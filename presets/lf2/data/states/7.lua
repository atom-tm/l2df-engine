--- Defend
return function (obj, data)
	local control = obj.C.controller
	if not control then return end

	if data.frame.id == 110 and control.pressed('left') ~= control.pressed('right') then
		data.facing = control.pressed('left') and -1 or 1
	end

	local attr = obj.C.attr
	if attr then
		local adata = attr.data()
		if adata.defence <= 0 then
			obj.C.frames.set('broken_defend')
		else
			adata.candefend = true
		end
	end
end