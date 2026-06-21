local object = require 'data.scripts.object'
local frame = require 'data.scripts.frame'

return function (obj, data)
	if frame.entered(data, 'teleport') then
		object.teleport(obj, 1)
	end
end
