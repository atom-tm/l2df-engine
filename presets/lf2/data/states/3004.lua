local object = require 'data.scripts.object'

return function (obj, data)
	object.projectile(obj, data, { shadow = false })
end
