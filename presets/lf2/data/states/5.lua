--- Dash
local frame = require 'data.scripts.frame'

local function applyJumpSpeed(data)
	if data.jspeedx then
		data.dvx = data.jspeedx
		data.jspeedx = nil
	end
	if data.jspeedz then
		data.dvz = data.jspeedz
		data.jspeedz = nil
	end
end

return function (obj, data)
	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	if data.next_facing then
		data.facing = data.next_facing
		data.next_facing = nil
	end
	if not data.isdashed then
		local adata = attr.data()
		data.dvy = adata.dash_height
		data.isdashed = true
		applyJumpSpeed(data)
		return
	elseif control.pressed('attack') then
		frame.set(obj, 'dash_attack', true)
		return
	elseif data.ground then
		frames.set(219)
		return
	end

	applyJumpSpeed(data)
	if data.dvx == 0 then
		local left = control.pressed('left')
		local right = control.pressed('right')
		local facing = data.facing
		local newfacing = left and -1 or right and 1 or data.next_facing or facing
		if facing ~= newfacing then
			data.next_facing = newfacing
			if data.frame.id == 213 then
				frames.set(214)
			elseif data.frame.id == 214 then
				frames.set(213)
			elseif data.frame.id == 216 then
				frames.set(217)
			elseif data.frame.id == 217 then
				frames.set(216)
			end
		end
	end
	if data.next == 0 then
		data.next = data.frame.id
	end
end
