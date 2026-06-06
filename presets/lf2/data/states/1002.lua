local object = require 'data.scripts.object'

return function (obj, data)
	object.weapon(obj, data, { thrown = true, ground_frame = 70 })
end
