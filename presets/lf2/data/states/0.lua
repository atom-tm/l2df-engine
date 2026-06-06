--- Standing / Idle
local rnd = data.random

local catch = require 'data.kinds.catch'
local frame = require 'data.scripts.frame'
local input = require 'data.scripts.input'
local normalHit = require 'data.kinds.normal_hit'
local object = require 'data.scripts.object'

local function clearWalkReleaseSlide(data)
	data._lf2_walk_release_slide = nil
	data._lf2_walk_release_subframe = nil
end

local function applyWalkReleaseSlide(data)
	local speed = data._lf2_walk_release_slide
	if not speed then
		return
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
end

return function (obj, data)
	if normalHit.processReaction(obj) or catch.processReaction(obj) then
		return
	end

	local control = obj.C.controller
	local frames = obj.C.frames
	local attr = obj.C.attr
	if not (control and frames and attr) then return end

	data.jspeedx = nil
	data.jspeedz = nil
	data.flip = nil
	local post_crouch_slide = data._lf2_post_crouch_slide
	data._lf2_post_crouch_slide = nil
	data._lf2_jump_air_speed = nil
	data._lf2_jump_air_delay = nil
	data._lf2_jump_walk_slide = nil
	data._lf2_jump_walk_slide_subframe = nil
	data._lf2_jump_walk_first = nil
	if post_crouch_slide then
		data.dvx = post_crouch_slide
	end
	applyWalkReleaseSlide(data)

	if not data.ground then
		frames.set(212)
		return
	end

	local up = control.pressed('up')
	local down = control.pressed('down')
	local left = control.pressed('left')
	local right = control.pressed('right')
	local adata = attr.data()
	if (data.hit_j or 0) == 0 and control.hitted('jump') then
		clearWalkReleaseSlide(data)
		if left ~= right then
			data.facing = left and -1 or 1
			data.jspeedx = adata.jump_distance
			data._lf2_jump_walk_slide = adata.walking_speed
			data._lf2_jump_walk_slide_subframe = 1
			data._lf2_jump_walk_first = true
		end
		data.jspeedz = up ~= down and adata.jump_distancez * (up and -1 or 1)
		frame.set(obj, 'jump', true)
	elseif adata.defence > 0 and (data.hit_d or 0) == 0 and control.hitted('defend') then
		clearWalkReleaseSlide(data)
		frame.set(obj, 'defend', true)
	elseif (data.hit_a or 0) == 0 and control.hitted('attack') then
		clearWalkReleaseSlide(data)
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
	elseif up ~= down or left ~= right then
		if input.doubled(obj, 'left') then
			clearWalkReleaseSlide(data)
			data.facing = -1
			frame.set(obj, 'running', true)
		elseif input.doubled(obj, 'right') then
			clearWalkReleaseSlide(data)
			data.facing = 1
			frame.set(obj, 'running', true)
		else
			clearWalkReleaseSlide(data)
			data.facing = left and -1 or right and 1 or data.facing
			frames.set('walking')
		end
	end
	data.isjumped = nil
	data.isdashed = nil
end
