--- Catch (Dance of Pain)
local core = assert(l2df, 'L2DF is not available')

local helper = core.import 'helper'
local frame = require 'data.scripts.frame'
local relationship = require 'data.scripts.relationship'

local sign = helper.sign

local function processReaction()
	return false
end

local function firstFrame(value)
	return frame.first(value)
end

local function cpoint(data)
	return data and (data.frame and data.frame.cpoint or data.cpoint)
end

local function setCaughtFrame(victim, frameid)
	if not (victim and frameid) then
		return false
	end
	if victim.data.frame and victim.data.frame.id == frameid then
		return false
	end
	local frames = victim.C and victim.C.frames
	if frames then
		frames.set(frameid)
		return true
	end
	return false
end

local function shiftObject(obj, dx, dy)
	local objdata = obj and obj.data
	if not objdata then
		return
	end
	objdata.x = (objdata.x or 0) + (dx or 0)
	objdata.y = (objdata.y or 0) + (dy or 0)
	objdata.dx, objdata.dy = 0, 0
	objdata.vx, objdata.vy = 0, 0
	objdata.dvx, objdata.dvy = 0, 0
end

local function release(catcher, victim)
	local cdata = catcher and catcher.data
	local vdata = victim and victim.data
	if cdata then
		cdata._lf2_caught = nil
		cdata._lf2_catch_timer = nil
		cdata._lf2_catch_entry_timer = nil
		cdata._lf2_catch_aligned = nil
		cdata._lf2_catch_shifted_130 = nil
		cdata._lf2_catch_hurt_timer = nil
		cdata._lf2_catch_hurt_delay = nil
		cdata._lf2_catch_attacks = nil
		cdata._lf2_catch_attack_delay = nil
		cdata._lf2_catch_total_attack_delay = nil
		cdata._lf2_pending_throw_lying = nil
	end
	if vdata then
		vdata._lf2_catcher = nil
		vdata._lf2_fall_ignore = nil
		if frame.hasState(vdata, 10) then
			setCaughtFrame(victim, 181)
		end
	end
end

local function try(catcher, victim, itr)
	if not (catcher and victim and itr and itr.catchingact and itr.caughtact) then
		return false
	end
	if relationship.isFriendly(catcher, victim) or victim.data._lf2_catcher then
		return false
	end
	if not (frame.hasState(victim.data, 16) or frame.hasState(victim.data, 11)) then
		return false
	end
	local direction = sign((victim.data.x or 0) - (catcher.data.x or 0))
	if direction ~= 0 then
		catcher.data.facing = direction
	end
	local catching = firstFrame(itr.catchingact)
	local caught = firstFrame(itr.caughtact) or 130
	if catching then
		frame.set(catcher, catching)
	end
	catcher.data.dx = 15 * (catcher.data.facing or 1)
	catcher.data.vx, catcher.data.dvx = 0, 0
	if catching == 120 then
		caught = 131
	end
	setCaughtFrame(victim, caught)
	catcher.data._lf2_caught = victim
	catcher.data._lf2_catch_timer = core:convert(43)
	catcher.data._lf2_catch_entry_timer = catching == 120 and core:convert(5) or nil
	catcher.data._lf2_catch_attacks = 0
	catcher.data._lf2_catch_attack_delay = 0
	victim.data._lf2_catcher = catcher
	victim.data._lf2_fall_ignore = catcher
	shiftObject(victim, -11 * (catcher.data.facing or 1), 0)
	catcher.data._lf2_catch_aligned = true
	return true
end

local function handle(e1, e2, itr, bdy)
	if e1 == e2 then return end
	if itr.owner ~= e1 then return end
	if bdy.owner ~= e2 then return end
	return try(e1, e2, itr)
end

return {
	handle = handle,
	firstFrame = firstFrame,
	cpoint = cpoint,
	setCaughtFrame = setCaughtFrame,
	shiftObject = shiftObject,
	release = release,
	try = try,
	processReaction = processReaction,
}
