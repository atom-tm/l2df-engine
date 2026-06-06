local object = require 'data.scripts.object'

return function (obj, data)
	object.weapon(obj, data, { on_ground = true })
end
