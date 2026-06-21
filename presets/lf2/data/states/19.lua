--- Fire Run
local normalHit = require 'data.kinds.normal_hit'

return function (obj, data)
	if normalHit.processReaction(obj) then
		return
	end

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
