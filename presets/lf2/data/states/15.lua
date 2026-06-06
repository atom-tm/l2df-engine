--- Misc state. Used for weapon throw, dash attack, running stop and other frames.
local frame = require 'data.scripts.frame'
local normalHit = require 'data.kinds.normal_hit'

local max = math.max

return function (obj, data)
	if normalHit.processReaction(obj) then
		return
	end

	local frames = obj.C.frames
	local control = obj.C.controller
	local attr = obj.C.attr
	if not (frames and control and attr) then return end

	if data.frame.id == 215 and frame.entered(data, 'crouch_wait') then
		data.wait = max(0, (data.wait or 0) - 2)
		data._lf2_crouch_updates = 0
	elseif data.frame.id == 215 then
		data._lf2_crouch_updates = (data._lf2_crouch_updates or 0) + 1
		if data._lf2_crouch_updates >= 2 then
			frames.set(0)
			return
		end
	else
		data._lf2_crouch_updates = nil
	end

	local up = control.pressed('up')
	local down = control.pressed('down')
	local left = control.pressed('left')
	local right = control.pressed('right')
	if data.frame.keyword == 'dash_attack' and data.ground and data.isdashed then
		frames.set('crouch')
	elseif (data.isjumped or data.flip) and data.ground and data.frame.keyword == 'crouch'
		and control.pressed('jump') and (data.flip or left or right)
	then
		if left or right then
			data.facing = left and -1 or 1
			data.flip = 1
		end
		local adata = attr.data()
		data.jspeedx = adata.dash_distance * (data.flip or 1)
		data.jspeedz = up ~= down and adata.dash_distancez * (up and -1 or 1)
		frame.set(obj, data.flip == 1 and 213 or 214, true)
		data.isjumped = nil
		data.flip = nil
	end
end
