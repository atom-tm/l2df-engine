local state = {}
	local c = battle.control
	local e = battle.entities
	function state:Start(object,frame,state,map)
		if object.variables.state570 == nil then object.variables.state570 = {} end
		local vars = object.variables.state570
		if state.time ~= nil and state.frame ~= nil then
			local id = 1
			if state.id ~= nil then id = state.id end
			if vars[id] == nil or state.rewrite == true then
				vars[id] = {
					frame = state.frame,
					time = state.time
				}
			end
		elseif state.stop ~= nil then
			if state.stop == true then
				local id = 1
				if state.id ~= nil then id = state.id end
				vars[id] = nil
			end
		end
	end

	function state:Update(object,frame,map)
		if object.variables.state570 ~= nil then
			local vars = object.variables.state570
			for id in pairs(vars) do
				if vars[id].time > 0 then
					vars[id].time = vars[id].time - 1
					if vars[id].time == 0 then
						e.setFrame(object, vars[id].frame)
						vars[id] = nil
					end
				end
			end
		end
	end
return state