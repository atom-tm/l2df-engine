local state = { variables = {} } -- | 610 | -- Исчезание\\Появление
-- 
---------------------------------------------------------------------
function state:Load(object)
	state.variables.step = 0
end
---------------------------------------------------------------------
function state:Processing(object,s)
	if object.first_tick then
		local opoint = object.o
		local target = object.o
		if s.start ~= nil then opoint = s.start end
		if s.finish ~= nil then target = s.finish end
		object.o = opoint
		state.variables.step = (target - opoint) / object.frame.wait
	end
	object.o = object.o + state.variables.step
end

return state