--- Jumping
-- When the character is in the air, you can press right or left to change the direction he is facing.
-- Pressing A will take him jump_attack.
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

local function applyDecayingSlide(data, field, subframe)
	local speed = data[field]
	if not speed then
		return
	end
	data.dvx = speed
	data[subframe] = 1 - (data[subframe] or 0)
	if data[subframe] == 0 then
		speed = speed - 1
		data[field] = speed > 0 and speed or nil
		if not data[field] then
			data[subframe] = nil
		end
	end
end

return function (obj, data)
	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	local frameid = data.frame.id
	local adata = attr.data()
	local dash_startup = (frameid == 213 or frameid == 214) and not data.isdashed
	if dash_startup and (data.jspeedx or data.jspeedz) then
		data.dvy = adata.dash_height
		data.isdashed = true
		applyJumpSpeed(data)
		return
	end

	if frameid ~= 212 then
		data._lf2_jump_armed = frameid == 211 and not data.isjumped or nil
		data._lf2_jump_delay = nil
		data._lf2_jump_generation = nil
	end

	if data._lf2_jump_walk_slide then
		if data._lf2_jump_walk_first then
			data.dvx = data._lf2_jump_walk_slide * 2
			data._lf2_jump_walk_slide = data._lf2_jump_walk_slide - 0.5
			data._lf2_jump_walk_first = nil
		else
			applyDecayingSlide(data, '_lf2_jump_walk_slide', '_lf2_jump_walk_slide_subframe')
		end
	end

	if not data.ground then
		applyJumpSpeed(data)
		if data._lf2_jump_air_speed then
			if (data._lf2_jump_air_delay or 0) > 0 then
				data._lf2_jump_air_delay = data._lf2_jump_air_delay - 1
			else
				data.dvx = data._lf2_jump_air_speed
			end
		end
		local left = control.pressed('left')
		local right = control.pressed('right')
		data.facing = left and -1 or right and 1 or data.facing
	end
	if frameid == 212 and data._lf2_jump_armed and not data.isjumped then
		local generation = data.___frame_generation or 0
		if data._lf2_jump_generation ~= generation then
			data._lf2_jump_generation = generation
			data._lf2_jump_delay = 1
			return
		end
		if (data._lf2_jump_delay or 0) > 0 then
			data._lf2_jump_delay = data._lf2_jump_delay - 1
			if data._lf2_jump_delay > 0 then
				return
			end
		end
		local launchx = data.jspeedx
		data.dvy = adata.jump_height
		data.isjumped = true
		data._lf2_jump_armed = nil
		data._lf2_jump_delay = nil
		data._lf2_jump_generation = nil
		applyJumpSpeed(data)
		if launchx then
			data._lf2_jump_walk_slide = nil
			data._lf2_jump_walk_slide_subframe = nil
			data._lf2_jump_walk_first = nil
			data._lf2_jump_air_speed = adata.jump_distance - 1
			data._lf2_jump_air_delay = 1
		end
		return
	end
	if frameid < 212 or frameid == 213 or frameid == 214 then return end
	if data.ground then
		frames.set('crouch')
	elseif control.hitted('attack') or control.pressed('attack') then
		frame.set(obj, 'jump_attack', true)
	else
		data.next = data.frame.id
	end
end
