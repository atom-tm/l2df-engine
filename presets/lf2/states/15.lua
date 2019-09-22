local state = { variables = {} } -- | 15 | -- Управление
-- 
---------------------------------------------------------------------
function state:Processing(object,s)

	if (object.hit_code == "314" or object.hit_code == "324") and s.fa ~= nil then object:setFrame(s.fa)
	elseif (object.hit_code == "318" or object.hit_code == "328") and s.fj ~= nil then object:setFrame(s.fj)
	elseif object.hit_code == "374" and s.ua ~= nil then object:setFrame(s.ua)
	elseif object.hit_code == "378" and s.uj ~= nil then object:setFrame(s.uj)
	elseif object.hit_code == "364" and s.da ~= nil then object:setFrame(s.da)
	elseif object.hit_code == "368" and s.dj ~= nil then object:setFrame(s.dj)
	end

	if s.aa ~= nil and object:double_timer("attack") then object:setFrame(s.aa) end
	if s.jj ~= nil and object:double_timer("jump") then object:setFrame(s.jj) end
	if s.dd ~= nil and object:double_timer("defend") then object:setFrame(s.dd) end
	if s.ss ~= nil and object:double_timer("special1") then object:setFrame(s.ss) end
	if s.bb ~= nil and ((object:double_timer("left") and object.facing == 1) or (object:double_timer("right") and object.facing == -1)) then object:setFrame(s.bb) end
	if s.ff ~= nil and ((object:double_timer("left") and object.facing == -1) or (object:double_timer("right") and object.facing == 1)) then object:setFrame(s.ff) end

	if s.a ~= nil and object:timer("attack") then object:setFrame(s.a) end
	if s.j ~= nil and object:timer("jump") then object:setFrame(s.j) end
	if s.d ~= nil and object:timer("defend") then object:setFrame(s.d) end
	if s.s ~= nil and object:timer("special1") then object:setFrame(s.s) end
	if s.b ~= nil and ((object:timer("left") and object.facing == 1) or (object:timer("right") and object.facing == -1)) then object:setFrame(s.b) end
	if s.f ~= nil and ((object:timer("left") and object.facing == -1) or (object:timer("right") and object.facing == 1)) then object:setFrame(s.f) end

end

return state