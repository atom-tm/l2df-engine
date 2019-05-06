local state = { variables = {} } -- | 610 | -- Исчезание\\Появление с таймером
-- 
---------------------------------------------------------------------
function state:Load(object)
	state.variables.timer = 0
	state.variables.step = 0
end
---------------------------------------------------------------------
function state:Update(object)
	if state.variables.timer > 0 then
		object.o = object.o + state.variables.step
		state.variables.timer = state.variables.timer - 1
	end
end
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.first_tick then
		local opacity = object.o
		local target = object.o
		local timer = object.frame.wait
		if s.start ~= nil then opacity = s.start end
		if s.finish ~= nil then target = s.finish end
		if s.timer ~= nil then timer = s.timer end
		object.o = opacity
		state.variables.step = (target - opacity) / timer
		state.variables.timer = timer
	end
end

return state