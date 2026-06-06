--- Caught
local catch = require 'data.kinds.catch'

return function (obj, data)
	if catch.processReaction(obj) then
		return
	end
	-- TODO: drop weapon
end
