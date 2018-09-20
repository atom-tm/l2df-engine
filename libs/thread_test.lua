require "libs.get"
require "libs.physics"

local entity_list
local result = {}

while true do

	entity_list = nil
	--result = {}

	while entity_list == nil do
		entity_list = love.thread.getChannel( 'entity_list' ):pop()
	end

	for en_id = 1, #entity_list do
		
		local en = entity_list[en_id] -- получаем объект
		local en_frame = GetFrame(en) -- получаем фрейм объекта
		local max_rad = en_frame.itr_radius + en_frame.body_radius +  en_frame.platform_radius

		if max_rad > 0 then
			for t_id = 1, #entity_list do -- для каждого объекта на карте
				if t_id ~= en_id then -- если проверяемый объект не является проверяющим объектом

					local target = entity_list[t_id] -- получает проверяемый объект
					local t_frame = GetFrame(target) -- получаем фрейм проверяемого объекта

					local distantion = math.sqrt(math.abs((en.x - target.x)^2) + math.abs((en.y - target.y)^2))

					if (en_frame.itr_radius > 0) and (t_frame.body_radius > 0) then
						if distantion < (en_frame.itr_radius + t_frame.body_radius) then
							for itr_id = 1, #en_frame.itrs do
								for body_id = 1, #t_frame.bodys do
									local itr = GetCollider(en_frame.itrs[itr_id], en)
									local body = GetCollider(t_frame.bodys[body_id], target)
									local result = collidersVerification(itr,body)
									if result.collision then
										local collision_entity = {
											target = t_id,
											itr = itr_id,
											body = body_id,
											info = result
										}
										table.insert(result, collision_entity)
									end
								end
							end
						end
					end
				end
			end
		end
	end

table.insert(result, "collision_entity")

if love.thread.getChannel( 'collisions' ):getCount() < 1 then
	love.thread.getChannel( 'collisions' ):push( result )
end

end