local state = { variables = {} } -- | 50 | -- Таймер с переходом в кадр
-- 
---------------------------------------------------------------------
function state:Load(object)
	state.variables.timer = 0
	state.variables.frame = 0
end
---------------------------------------------------------------------
function state:Update(object)
	if state.variables.timer > 0 then
		state.variables.timer = state.variables.timer - 1
		if state.variables.timer == 0 then
			object:setFrame(state.variables.frame)
		end
	end
end
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.first_tick then
		if s.frame ~= nil then state.variables.frame = s.frame end
		if s.timer ~= nil then state.variables.timer = s.timer end
	end
end

return state