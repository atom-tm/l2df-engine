local helper = core.import 'helper'

return function (obj, data, params)
	local control = obj.C.controller
	if not control then return end
	if control:pressed('up') then data.dvy = data.dvy - 2 end
	if control:pressed('down') then data.dvy = data.dvy + 2 end
	if control:pressed('left') then data.dvx = data.dvx - 4 end
	if control:pressed('right') then data.dvx = data.dvx + 4 end
end