local l = {}
for i = 1, 10 do
	l[i] = Room()
end
EntityManager:addMulti(l)

for i = 4, 7 do
	EntityManager:removeById(i)
end

for i = 1, 5 do
	EntityManager:add(Room())
end

for i = 1, 5 do
	EntityManager:create(Room)
end