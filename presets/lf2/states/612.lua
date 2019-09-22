local state = { variables = {} } -- | 612 | -- Случайный wait
-- 
---------------------------------------------------------------------
function state:Load(object)
	state.variables.status = false
end
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.first_tick then
		if not state.variables.status then
			if s.wait ~= nil and type(s.wait) == "number" then
				object.wait = math.random(object.frame.wait, s.wait)
				state.variables.status = true
			end
		else state.variables.status = false end
	end
end

return state