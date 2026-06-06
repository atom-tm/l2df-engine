local object = require 'data.scripts.object'

return function (obj, data)
	object.weapon(obj, data, { on_ground = true })
	if data.ground and obj.C.frames then
		obj.C.frames.set(60)
	end
end
