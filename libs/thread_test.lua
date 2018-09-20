local entity_list
local result

while true do

	entity_list = nil
	result = {}

	while entity_list == nil do
		entity_list = love.thread.getChannel( 'entity_list' ):pop()
	end

	r = math.random(1,3)
	for en_id = 1, #entity_list do
		for i=1, r do
			table.insert(result, en_id)
		end
	end


	if love.thread.getChannel( 'collisions' ):getCount() < 1 then
		love.thread.getChannel( 'collisions' ):push( result )
	end

end