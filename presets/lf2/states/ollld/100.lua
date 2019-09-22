local state = {} -- | 100 | -- Движение с ускорением
-- maxSpeed_x\y\z - максимальная скорость движения
-- acceleration_x\y\z - ускорение каждый тик
-- Стейт позволяет объекту постепенно набирать скорость по осям X\Y\Z. Если скорость уже набрана, объект продолжает движение с равномерной скоростью. Если скорость превышает заданную в переменной MaxSpeed, ничего не происходит.
---------------------------------------------------------------------
function state:Processing(object,s)
	if s.maxSpeed_x * object.facing > 0 then
		if object.vel_x < s.maxSpeed_x then
			object:addMotion_X(s.acceleration_x)
			if object.vel_x > s.maxSpeed_x then
				object:setMotion_X(s.maxSpeed_x)
			end
			object.noGravity = true
		end
	elseif s.maxSpeed_x * object.facing < 0 then
		if object.vel_x > -s.maxSpeed_x then
			object:addMotion_X(-s.acceleration_x)
			if object.vel_x < -s.maxSpeed_x then
				object:setMotion_X(-s.maxSpeed_x)
			end
			object.noGravity = true
		end
	end
	
	--[[if s.maxSpeed_x ~= nil and s.acceleration_x then
		if math.abs(object.vel_x) < math.abs(s.maxSpeed_x) then
			object:addMotion_X(s.acceleration_x * object.facing)
			if math.abs(object.vel_x) > math.abs(s.maxSpeed_x) then
				object:setMotion_X(s.maxSpeed_x * object.facing)
			end
		end
	end
	if object.vel_y < s.maxSpeed_y then
		object:addMotion_Y(s.acceleration_y)
		if object.vel_y > s.maxSpeed_y then
			object:setMotion_Y(s.maxSpeed_y)
		end
	end
	if object.vel_z < s.maxSpeed_z then
		object:addMotion_Z(s.acceleration_z)
		if object.vel_z > s.maxSpeed_z then
			object:setMotion_Z(s.maxSpeed_z)
		end
	end]]
end

return state