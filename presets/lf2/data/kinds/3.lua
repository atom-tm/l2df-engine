--- Catch any body. Used by Louis whirlwind throw frames.
local catch = require 'data.kinds.catch'

return function (e1, e2, itr, bdy)
	if e1 == e2 then return false end
	if itr.owner ~= e1 or bdy.owner ~= e2 then return false end
	return catch.try(e1, e2, itr, true)
end
