local state = {}
	local c = battle.control
	function state:Start(object,frame,state,map)

		if state.rx1 ~= nil and state.rx2 ~= nil then
			object.taccel_x = object.taccel_x + math.random(state.rx1, state.rx2) * object.facing
		elseif state.rx1 ~= nil then
			object.taccel_x = object.taccel_x + math.random(0, state.rx1) * object.facing
		elseif state.rx2 ~= nil then
			object.taccel_x = object.taccel_x + math.random(0, state.rx2) * object.facing
		end

		if state.ry1 ~= nil and state.ry2 ~= nil then
			object.taccel_y = object.taccel_y + math.random(state.ry1, state.ry2)
		elseif state.ry1 ~= nil then
			object.taccel_y = object.taccel_y + math.random(0, state.ry1)
		elseif state.ry2 ~= nil then
			object.taccel_y = object.taccel_y + math.random(0, state.ry2)
		end
		if state.rz1 ~= nil and state.rz2 ~= nil then
			object.taccel_z = object.taccel_z + math.random(state.rz1 * 100, state.rz2 * 100) * 0.01
		elseif state.rz1 ~= nil then
			object.taccel_z = object.taccel_z + math.random(0, state.rz1 * 100) * 0.01
		elseif state.rz2 ~= nil then
			object.taccel_z = object.taccel_z + math.random(0, state.rz2 * 100) * 0.01
		end


	end
return state