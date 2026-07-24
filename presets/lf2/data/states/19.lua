--- Fire Run
local core = assert(l2df, 'L2DF is not available')
local normalHit = require 'data.kinds.normal_hit'
local object = require 'data.scripts.object'

local function spawnSmoke(obj, data)
	data._lf2_firerun_smoke_tick = (data._lf2_firerun_smoke_tick or 0) - 1
	if data._lf2_firerun_smoke_tick > 0 then
		return
	end
	data._lf2_firerun_smoke_tick = core:convert(3)
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

	local control = obj.C.controller
	local attr = obj.C.attr
	local adata = attr and attr.data()
	if not (control and adata) then
		return
	end

	if control.pressed('up') ~= control.pressed('down') then
		data.dvz = (control.pressed('up') and -1 or 1) * adata.running_speedz
	end
end
