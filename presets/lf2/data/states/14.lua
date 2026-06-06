--- Lying
local catch = require 'data.kinds.catch'
local normalHit = require 'data.kinds.normal_hit'

return function (obj, data)
	if normalHit.processReaction(obj) or catch.processReaction(obj) then
		return
	end
	local attr = obj.C.attr
	if not attr then return end
	if attr.data().hp <= 0 then
		data.next = data.frame.id
	end
end
