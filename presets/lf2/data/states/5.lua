--- Dash
return function (obj, data, params)
	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	if data.next_facing then
		data.facing = data.next_facing
		data.next_facing = nil
	end

	if not data.isdashed then
		data.dvy = attr.data().dash_height
		data.isdashed = true
	elseif data.ground then
		return frames.set('crouch')
	elseif control.pressed('attack') and (data.vx > 0) == (data.facing == 1) then
		-- TODO: dash_weapon_attack
		return frames.set('dash_attack')
	end

	if data.jspeedx then
		data.dvx = data.jspeedx
		data.jspeedx = nil
	end
	if data.jspeedz then
		data.dvz = data.jspeedz
		data.jspeedz = nil
	end

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