local core = assert(l2df, 'L2DF is not available')

local frame = require 'data.scripts.frame'
local input = require 'data.scripts.input'
local normalHit = require 'data.kinds.normal_hit'
local object = require 'data.scripts.object'

local function processNext1000(obj, data)
	local frameid = data.frame and data.frame.id
	if data._lf2_next_1000_frame and data._lf2_next_1000_frame ~= frameid then
		data._lf2_next_1000_frame = nil
		data._lf2_next_1000_timer = nil
	end
	if tonumber(data.next) ~= 1000 and not data._lf2_next_1000_timer then
		return false
	end
	if not data._lf2_next_1000_timer then
		data._lf2_next_1000_frame = frameid
		data._lf2_next_1000_timer = core:convert((data.wait or 0) + 1)
	end
	data.next = frameid or data.next
	if data._lf2_next_1000_timer <= 0 then
		object.despawn(obj)
		return true
	end
	data._lf2_next_1000_timer = data._lf2_next_1000_timer - 1
	return false
end

return function (obj, data)
	if processNext1000(obj, data) then
		return
	end
	object.processHeal(obj, data)
	if object.transformFromState(obj, data) then
		return
	end
	local control = obj.C.controller
	local frames = obj.C.frames
	if control and frames then
		if not input.handleSpecial(obj, data) then
			if (data.hit_d or 0) ~= 0 and control.hitted('defend') then
				frame.set(obj, data.hit_d, true)
			elseif (data.hit_j or 0) ~= 0 and control.hitted('jump') then
				frame.set(obj, data.hit_j, true)
			elseif (data.hit_a or 0) ~= 0 and control.hitted('attack') then
				frame.set(obj, data.hit_a, true)
			end
		end
	end
	normalHit.processPending(obj)
	object.prepareFrame(obj, data, {
		scale_motion = not data._lf2_type or data._lf2_type == 0,
	})
	object.processOpoint(obj, data, frame.entered)
end
