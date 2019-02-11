local state = { variables = {} } -- | 16 | -- Удержание
-- 
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.wait == 0 then
		if s.a ~= nil and object:pressed("attack") then object:setFrame(s.a) end
		if s.j ~= nil and object:pressed("jump") then object:setFrame(s.j) end
		if s.d ~= nil and object:pressed("defend") then object:setFrame(s.d) end
		if s.s ~= nil and object:pressed("special1") then object:setFrame(s.s) end
		if s.b ~= nil and ((object:pressed("left") and object.facing == 1) or (object:pressed("right") and object.facing == -1)) then object:setFrame(s.b) end
		if s.f ~= nil and ((object:pressed("left") and object.facing == -1) or (object:pressed("right") and object.facing == 1)) then object:setFrame(s.f) end
	end
end

return state