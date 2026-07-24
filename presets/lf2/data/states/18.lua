--- Burning
local core = assert(l2df, 'L2DF is not available')
local normalHit = require 'data.kinds.normal_hit'
local object = require 'data.scripts.object'

local function spawnSmoke(obj, data)
	data._lf2_burning_smoke_tick = (data._lf2_burning_smoke_tick or 0) - 1
	if data._lf2_burning_smoke_tick > 0 then
		return
	end
	data._lf2_burning_smoke_tick = core:convert(3)
	object.spawnObject(obj, {
		oid = 999,
		action = 140,
		x = data.centerx or 0,
		y = data.centery or 0,
		dvx = 0,
		dvy = 550,
		dvz = 0,
		facing = 0,
	})
end

return function (obj, data)
	if normalHit.processReaction(obj) then
		return
	end
	spawnSmoke(obj, data)

	local frames = obj.C.frames
	if not frames then
		return
	end

	if not data.ground or (data.dvy or 0) ~= 0 or (data.vy or 0) ~= 0 then
		data._lf2_burning_airborne = true
	end

	if data.ground and data._lf2_burning_airborne and (data.dvy or 0) == 0 and (data.vy or 0) == 0 then
		data._lf2_burning_airborne = nil
		frames.set(185)
		return
	end

	local id = data.frame and data.frame.id
	if id and id >= 203 and id <= 206 then
		if (data.vy or 0) > 0 and id >= 205 then
			frames.set(203)
		elseif (data.vy or 0) <= 0 and id <= 204 then
			frames.set(205)
		end
	end
end
