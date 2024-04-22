--- Jumping
-- When the character is in the air, you can press right or left to change the direction he is facing.
-- Pressing A will take him jump_attack.
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
	elseif control.pressed('attack') then
		-- TODO: jump_weapon_attack
		frames.set('jump_attack')
	else
		data.next = data.frame.id
	end
end