local tr, r = 1 / 60
GSID:seed(1, tr)
x, y = { }, { }
for i = 1, 100 do
	x[i] = 0
	y[i] = 0
end
for i = 1, 1000 do
	GSID:advance(tr)
	for k = 1, 20 do
		r = math.floor(math.random() * 100) + 1
		x[r] = x[r] + 1
		r = GSID:rand() % 100 + 1
		y[r] = y[r] + 1
	end
end
for i = 0, 9 do
	print(
		'LUA5',
		x[i * 10 + 1],
		x[i * 10 + 2],
		x[i * 10 + 3],
		x[i * 10 + 4],
		x[i * 10 + 5],
		x[i * 10 + 6],
		x[i * 10 + 7],
		x[i * 10 + 8],
		x[i * 10 + 9],
		x[i * 10 + 10]
	)
	print(
		'GSID',
		y[i * 10 + 1],
		y[i * 10 + 2],
		y[i * 10 + 3],
		y[i * 10 + 4],
		y[i * 10 + 5],
		y[i * 10 + 6],
		y[i * 10 + 7],
		y[i * 10 + 8],
		y[i * 10 + 9],
		y[i * 10 + 10]
	)
end