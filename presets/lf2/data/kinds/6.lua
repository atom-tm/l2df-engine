--- Super punch
local frame = require 'data.scripts.frame'

return function (e1, e2, itr, bdy)
	if itr.owner == bdy.owner then
		return
	end
	local attr = e2.C.attr
	if attr then
		attr.data().cansuper = true
	end
	local control = e2.C.controller
	if control and (control.hitted('attack') or control.pressed('attack')) then
		frame.set(e2, 70, true)
		return true
	end
end
