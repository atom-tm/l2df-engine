--- Broken defend
local normalHit = require 'data.kinds.normal_hit'

return function (obj, data)
	if normalHit.processReaction(obj) then
		return
	end
	-- local attr = obj.C.attr
	-- if not attr then return end
	-- if data.frame.id == 114 then
	-- 	attr.restoreDefence()
	-- end
end
