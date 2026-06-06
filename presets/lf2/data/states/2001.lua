local object = require 'data.scripts.object'

return function (obj, data)
	object.weapon(obj, data, { on_hand = true })
end
