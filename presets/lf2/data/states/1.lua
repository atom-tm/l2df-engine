--- Walking
local rnd = data.random

local frame = require 'data.scripts.frame'
local input = require 'data.scripts.input'
local object = require 'data.scripts.object'

local function clearWalkReleaseSlide(data)
	data._lf2_walk_release_slide = nil
	data._lf2_walk_release_subframe = nil
end

local function startWalkReleaseSlide(data, speed)
	if not speed or speed <= 1 then
		return
	end
	data._lf2_walk_release_slide = speed - 1
	data._lf2_walk_release_subframe = 1
end

local function applyWalkReleaseSlide(data)
	local speed = data._lf2_walk_release_slide
	if not speed then
		return nil
	end
	data.dvx = speed
	local subframe = data._lf2_walk_release_subframe or 1
	if subframe == 2 then
		speed = speed - 1
		data._lf2_walk_release_slide = speed > 0 and speed or nil
		data._lf2_walk_release_subframe = data._lf2_walk_release_slide and 1 or nil
	else
		data._lf2_walk_release_subframe = subframe + 1
	end
	return speed
end

return function (obj, data)
	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	local adata = attr.data()
	local def = (data.hit_d or 0) == 0 and control.hitted('defend')
	local jmp = (data.hit_j or 0) == 0 and control.hitted('jump')
	local atk = (data.hit_a or 0) == 0 and control.hitted('attack')
	local speedx = adata.walking_speed
	local speedz = adata.walking_speedz
	local left = control.pressed('left')
	local right = control.pressed('right')
	local up = control.pressed('up')
	local down = control.pressed('down')
	if speedx then
		if left ~= right then
			clearWalkReleaseSlide(data)
			data.dvx = speedx
			data.facing = left and -1 or 1
		elseif up ~= down then
			clearWalkReleaseSlide(data)
			data.dvx = 0
			data.vx = 0
		elseif not data._lf2_walk_release_slide and data.vx ~= 0 then
			startWalkReleaseSlide(data, speedx)
		end
	end
	local slide = applyWalkReleaseSlide(data)
	if speedz then
		if up then data.dvz = data.dvz - speedz end
		if down then data.dvz = data.dvz + speedz end
	end

	if adata.defence > 0 and def then
		frame.set(obj, 'defend', true)
	elseif jmp then
		if left ~= right then
			data.jspeedx = adata.jump_distance
			data._lf2_jump_walk_slide = adata.walking_speed
			data._lf2_jump_walk_slide_subframe = 1
			data._lf2_jump_walk_first = true
		end
		data.jspeedz = up ~= down and adata.jump_distancez * (up and -1 or 1)
		frame.set(obj, 'jump', true)
	elseif atk then
		if left ~= right then
			data.facing = left and -1 or 1
		end
		if data._lf2_weapon then
			data._lf2_weapon_swing = not data._lf2_weapon_swing
			frame.set(obj, data._lf2_weapon_swing and 20 or 25, true)
		elseif object.pickupWeapon(obj) then
			frame.set(obj, 115, true)
		else
			frame.set(obj, adata.cansuper and 'super_punch' or rnd(2) == 1 and 60 or 65, true)
		end
	elseif left and not right and input.doubled(obj, 'left') then
		clearWalkReleaseSlide(data)
		data.facing = -1
		frame.set(obj, 'running', true)
	elseif right and not left and input.doubled(obj, 'right') then
		clearWalkReleaseSlide(data)
		data.facing = 1
		frame.set(obj, 'running', true)
	elseif slide and slide <= 1 then
		frames.set('standing')
	elseif data.dvz == 0 and data.dvx == 0 then
		frames.set('standing')
	else
		data.next = (data.frame.id - 4) % (adata.walking_frame_rate + 1) + 5
	end
end
