local core = assert(l2df, 'L2DF is not available')

local frame = require 'data.scripts.frame'

local M = { }

local LF2_DOUBLE_TAP_WINDOW = core:convert(9)

function M.doubled(obj, key)
	local data = obj and obj.data
	local doubled = data and data._lf2_double
	if doubled and doubled[key] then
		return true
	end
	local control = obj and obj.C and obj.C.controller
	return control and control.doubled and control.doubled(key, LF2_DOUBLE_TAP_WINDOW) or false
end

function M.handleSpecial(obj, data)
	local control = obj and obj.C and obj.C.controller
	local frames = obj and obj.C and obj.C.frames
	if not (control and frames) then
		return false
	end
	local defending = control.pressed('defend')
		or data.frame and (data.frame.id == 110 or data.frame.id == 111)
	if not defending then
		return false
	end

	local facing = data.facing or 1
	local forward = control.pressed(facing == 1 and 'right' or 'left')
	local back = control.pressed(facing == 1 and 'left' or 'right')
	local up = control.pressed('up')
	local down = control.pressed('down')
	local attack = control.hitted('attack')
	local jump = control.hitted('jump')
	local target

	if (attack and control.pressed('jump') or jump and control.pressed('attack')) then
		target = frame.first(data.hit_ja)
	elseif attack and up then
		target = frame.first(data.hit_Ua)
	elseif attack and down then
		target = frame.first(data.hit_Da)
	elseif attack and forward then
		target = frame.first(data.hit_Fa)
	elseif attack and back then
		target = frame.first(data.hit_Ba)
	elseif jump and up then
		target = frame.first(data.hit_Uj)
	elseif jump and down then
		target = frame.first(data.hit_Dj)
	elseif jump and forward then
		target = frame.first(data.hit_Fj)
	elseif jump and back then
		target = frame.first(data.hit_Bj)
	end

	if target and target ~= 0 then
		frame.set(obj, target, true)
		return true
	end
	return false
end

return M
