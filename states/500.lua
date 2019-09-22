local state = { variables = {} } -- | 500 | -- Техника
-- Стейт для реализации механики ручных печатей
---------------------------------------------------------------------
function state:Load(object)
	state.variables.code = ""
end
---------------------------------------------------------------------
function state:Processing(object,s)
	if object:pressed("special1") then
		if object:hit("up") and s.up ~= nil then
			object:setFrame(s.up)
			state.variables.code = state.variables.code .. "u"
		elseif object:hit("down") and s.down ~= nil then
			object:setFrame(s.down)
			state.variables.code = state.variables.code .. "d"
		elseif (object:hit("left") or object:hit("right")) and s.forward ~= nil then
			if object:hit("left") then object.facing = -1 end
			if object:hit("right") then object.facing = 1 end
			object:setFrame(s.forward)
			state.variables.code = state.variables.code .. "f"
		end
		if object.wait == 0 then
			object.wait = object.frame.wait
		end
	else
		if object.wait == 0 then
			object:setFrame(state.variables.code)
			state.variables.code = ""
		end
	end
end

return state