data_list = {} -- таблица, содержащая в себе id каждого объекта из data.txt и путь до файла этого объекта
maps_list = {} -- таблица, содержащая в себе id каждой карты из data.txt

head_list = {} -- таблица в которой будут храниться имена персонажей, их айди и аватарки для меню выбора персонажа

loading_list = {
	characters = {},
	map = ""
} -- список файлов, которые нужно загрузить в память перед началом боя 
sourse_list = {} -- массив, хранящий в себе все объекты, доступные к загрузке

images_list = {} -- таблица в которой хранятся все изображения, подружаемые в память в начале боя. Чтобы не подгружать одни и те же изображения несколько раз для каждого персонажа, они будут загружаться сюда единожды, с помощью специальной функции, а в персонажа будешь лишь отдаваться ссылка на данное изображение

entity_list = {} -- массив, хранящий в себе все объекты, находящиеся на сцене
map = {} -- таблица с информацией о текущей карте



function CreateDataList() -- вызываемая при запуске игры, функция перебирает файл data.txt, составляя список доступных к загрузке объектов в формате [id] - [путь к файлу]
-------------------------------------

	local data = love.filesystem.read("data.txt") -- получаем содержимое файла data.txt

	local characters = string.match(data, "%[characters%]([^%[%]]+)") -- берём всех из списка [characters]
	local objects = string.match(data, "%[objects%]([^%[%]]+)") -- берём всех из списка [objects]

	local maps = string.match(data, "%[maps%]([^%[%]]+)") -- получаем содержимое списка [maps]


	for id, file in string.gmatch(characters, "id: (%d+)%s+file: ([%w._/]+)") -- для каждого персонажа
	do
		id = tonumber(id)
		if data_list[id] == nil then -- смотрим в список объектов, проверяем на схожесть id
			data_list[id] = file -- если id свободен, загружаем персонажа под этим id

		else -- если id занят, уведомим об этом игрока с помощью ошибки (хз зачем)
			love.window.showMessageBox( "Duplicate id for file", "["..id .. "] " .. file, "info", true)
		end
	end

	for id, file in string.gmatch(objects, "id: (%d+)%s+file: ([%w._/]+)") -- для каждого объекта
	do
		id = tonumber(id)
		if data_list[id] == nil then -- смотрим в список объектов, проверяет на схожесть id
			data_list[id] = file -- если id свободен, загружаем персонажа под этим id
		else -- если id занят, уведомим об этом игрока с помощью ошибки (хз зачем) 
			love.window.showMessageBox( "Duplicate id for file", "["..id .. "] " .. file, "info", true)
		end
	end

	for id, file in string.gmatch(maps, "id: (%d+)%s+file: ([%w._/]+)") -- для каждой карты
	do
		id = tonumber(id)
		if maps_list[id] == nil then -- смотрим в список карт, проверяем на схожесть id
			maps_list[id] = file -- если id свободен, загружаем карту под этим id
		else -- если id занят, опять уведомим игрока, люблю ошибочки
			love.window.showMessageBox( "Duplicate id for file", "["..id .. "] " .. file, "info", true)
		end
	end
end



function LoadingBeforeBattle() -- функция вызывается перед началом каждого боя. Она очищает массивы объектов и изображений, затем перебирает список loading_list и загружает в память все файлы и картинки. В конце очищая список файлов на загрузку
-------------------------------------

	images_list = {}
	sourse_list = {}
	entity_list = {}
	map = nil
	collectgarbage()

	for i in pairs(loading_list.characters) do
		LoadEntity(loading_list.characters[i])
	end -- цикл загрузки объектов из списка

	map = LoadMap(loading_list.map)
	CameraSet(map.width, map.height)

	Spawner() -- функция отвечающая за спавн всех игроков на карте

end



function LoadImage(path) -- функция проверяет наличие указанного изображения в списке загруженных. если изображение уже загружено в память, оно не будет загружено заново, а функция вернёт ссылку на загруженную картинку.
-------------------------------------
	local returned_image -- сюда положим возвращаемую картику

	for i in pairs(images_list) do -- пробегаемся по массиву уже загруженных картинок
		if images_list[i].file_path == path then
			returned_image = images_list[i].image
		end
	end -- если такая картинка уже загружена в массив, она будет положена в возвращаемую переменную

	if returned_image == nil then -- если после поиска по массиву, изображение не нашлось
		returned_image = love.graphics.newImage(path) -- загружаем пикчу
		new_image = {
			file_path = path,
			image = returned_image
		} -- создаём ресурс картинки с путём до файла и самим загруженным изображением
		table.insert(images_list, new_image) -- вставляем ресурс картинки в массив изображений
	end -- если такой картинки ещё нет в массиве, она будет загружена туда и возвращена

	return returned_image -- возвращаем картинку
end



function SpriteCutting(w,h,x,y,image,border) -- нарезка спрайт листа на отдельные изображения. Функия возвращает что-то вроде "масок", которые при отрисовке накладываются на спрайт-лист.
-------------------------------------
	
	local pics = {} -- тут будут лежать все "маски"

	for i = 0, y - 1 do
		for j = 0, x - 1 do
			if border then
				pics[#pics + 1] = love.graphics.newQuad(w*j, h*i , w - 1, h - 1, image:getDimensions())
			else
				pics[#pics + 1] = love.graphics.newQuad(w*j, h*i ,w,h, image:getDimensions())
			end
		end
	end -- процесс нарезки

	return pics -- возвращаем "сетку", которая будет накладываться на лист со спрайтами
end



function LoadMap(map_id) -- функция загружает, путём парсинга кода, карту с указанным id в переменную и возвращает её
-------------------------------------
	local map = {} -- создаём переменную карты

	local file = maps_list[map_id] -- получаем путь до файла карты
	local dat = love.filesystem.read(file) -- считываем информацию из файла карты

	if not (dat == nil) then -- если дат файл не пустой, идёт попытка его парсинга

		map.name = PString(dat, "name")
		map.width = PNumber(dat, "width")
		map.height = PNumber(dat, "height")

		map.shadow = PBool(dat, "shadow")
		map.shadow_opacity = PNumber(dat, "shadow_opacity")

		map.border_up = PNumber(dat, "border_up")
		map.border_down = PNumber(dat, "border_down")

		map.area = math.abs(map.border_down - map.border_up)
		map.z_center = (map.border_up + map.border_down) * 0.5

		map.layers = {} -- массив задников карты
		for l in string.gmatch(dat, "layer: {([^{}]*)}") do -- для каждого блока layer: {}
			
			local layer = {} -- переменная слоя
			local path = string.match(l, "file: \"(.*)\"") -- путь до файла слоя
			
			layer.image = LoadImage(path)

			if PBool(l, "fsaa") then
				layer.image:setFilter("linear","linear")
			else
				layer.image:setFilter("nearest","nearest")
			end

			layer.x = PNumber(l, "x")
			layer.y = PNumber(l, "y")

			table.insert(map.layers, layer) -- загрузка коллайдера в массив
		end
		
		map.filters = {} -- массив фильтров карты
		for f in string.gmatch(dat, "filter: {([^{}]*)}") do -- для каждого блока filter: {}
			
			local filter = {} -- переменная слоя
			local path = string.match(f, "file: \"(.*)\"") -- путь до файла слоя
			
			filter.image = LoadImage(path)

			if PBool(f, "fsaa") then
				filter.image:setFilter("linear","linear")
			else
				filter.image:setFilter("nearest","nearest")
			end

			filter.x = PNumber(f, "x")
			filter.y = PNumber(f, "y")

			table.insert(map.filters, filter) -- загрузка коллайдера в массив
		end

		map.spawn_points = {} -- массив фильтров карты
		for sp in string.gmatch(dat, "spawn_point: {([^{}]*)}") do -- для каждого блока filter: {}
			local spawn_point = {} -- переменная слоя
			spawn_point.x = PNumber(sp, "x")
			spawn_point.y = PNumber(sp, "y")
			spawn_point.z = PNumber(sp, "z")
			spawn_point.rx = PNumber(sp, "rx")
			spawn_point.ry = PNumber(sp, "ry")
			spawn_point.rz = PNumber(sp, "rz")
			spawn_point.facing = PNumber(sp, "facing")
			table.insert(map.spawn_points, spawn_point) -- загрузка коллайдера в массив
		end

	end
	return map
end


function LoadEntity(id) -- функция загружает, путём парсинга кода, объект в массив "sourse_list", откуда в будущем будут создаваться копии исходного объекта для их спавна в бою
-------------------------------------
	
	local object_is_loaded = false -- флаг того что объект с таким id уже загружен

	for sourse = 1, #sourse_list do -- ищем id в списке загруженных объектов
		if sourse_list[sourse].id == id then 
			object_is_loaded = true -- если объект найден в списке, ставим флажок что его не надо загружать
		end
	end


	if not object_is_loaded then -- если объект ещё не загружен

		local en = {} -- создаём объект

		local file = data_list[id] -- помещаем ссылку на файл загружаемого объекта
		local dat = love.filesystem.read(file) -- помещаем в строку содержимое файла персонажа


		if not (dat == nil) then -- если датка не пустая, пытаемся её парсить

			local head = string.match(dat, "<head>(.*)</head>") -- подгружаем содержимое <head></head>

			if not (head == nil) then -- если head не пустой, парсим его

				en.name = string.match(head, "name: ([%w_% ]+)")
				en.type = PString(head, "type")
				en.weight = PNumber(head, "weight")
				en.physic = PBool(head, "physic")
				en.collision = PBool(head, "collision")

				en.sprites = {} -- массив со спрайтами персонажа

				for s in string.gmatch(head, "sprite: {([^{}]*)}") do -- для каждого блока спрайтов

					local path = string.match(s, "file: \"(.*)\"")
					local image = LoadImage(path) -- получение спрайт листа из массива изображений
					local w = PNumber(s, "w")
					local h = PNumber(s, "h")
					local row = PNumber(s, "row")
					local col = PNumber(s, "col")
					local border = PBool(s, "border")
					local pics = SpriteCutting(w,h,row,col,image, border) -- получение "сетки" спрайтов

					local sprites = {
						file = image,
						pics = pics
					} -- объект спрайт-сетки

					table.insert(en.sprites,sprites) -- добавляем объект в массив
				end
			end

			en.vars = {} -- массив с дополнительными переменными
			local vars = string.match(dat, "<vars>(.*)</vars>") -- получаем содержимое блока <vars></vars>
			
			if not (vars == nil) then -- если блок содержит что-то, пытаемся парсить это на переменные
				for key, value in string.gmatch(vars, "([%w_]+): ([%w_-%d%.])") do
					en.vars[key] = value
				end
			end

			en.frames = {} -- массив с фреймами

			for f in string.gmatch(dat, "<frame>([^<>]*)</frame>") do -- для каждого блока <frame></frame>
				
				local frame = {} -- создаём пустой фрейм
				local frame_number = string.match(f, "(%d+)") -- получаем номер фрейма 

				frame.pic = PNumber(f,"pic")
				frame.next = PNumber(f,"next")
				frame.wait = PNumber(f,"wait")
				frame.centerx = PNumber(f,"centerx")
				frame.centery = PNumber(f,"centery")
				frame.shadow = PNumber(f,"shadow")
				
				frame.hold_left = PNumber(f,"hold_left")
				frame.double_left = PNumber(f,"double_left")

				frame.bodys = {} -- массив с коллайдерами body персонажа
				local r = {} -- переменная для нахождения радиуса хитбоксов
				

				for b in string.gmatch(f, "body: {([^{}]*)}") do -- для каждого блока body: {}
					local collaider = LoadCollider(b,r) -- получение коллайдера
					-- сюда вставлять дополнительные теги
					table.insert(frame.bodys, collaider) -- загрузка коллайдера в массив
				end
				frame.body_radius = FindMaximum(r) -- получение радиуса body коллайдеров


				frame.itrs = {} -- массив с коллайдерами itr персонажа
				r = {} -- переменная для нахождения радиуса хитбоксов
				for i in string.gmatch(f, "itr: {([^{}]*)}") do -- для каждого блока itr: {}
					local collaider = LoadCollider(i,r) -- получение коллайдера
					-- сюда вставлять дополнительные теги
					table.insert(frame.itrs, collaider) -- загрузка коллайдера в массив
				end
				frame.itr_radius = FindMaximum(r) -- получение радиуса коллайдеров


				frame.platforms = {} -- массив с коллайдерами platform персонажа
				r = {} -- переменная для нахождения радиуса хитбоксов
				for p in string.gmatch(f, "platform: {([^{}]*)}") do -- для каждого блока platform: {}
					local collaider = LoadCollider(p,r) -- получение коллайдера
					-- сюда вставлять допольнительные теги
					table.insert(frame.platforms, collaider) -- загрузка коллайдера в массив
				end
				frame.platform_radius = FindMaximum(r) -- получение радиуса коллайдеров


				en.frames[frame_number] = frame -- добавление фрейма в массив фреймов
			end
		end

		local sourse = {
			id = id,
			en = en
		} -- создаём ресурс
		table.insert(sourse_list,sourse) -- добавляем в список ресурсов, чтобы избежать повторных загрузок этого-же объекта и разгрузить процессор
	end
end


function LoadCollider(c,r)
	local collaider = {}
		collaider.x = tonumber(string.match(c, "x: ([-%d]+)"))
		collaider.y = tonumber(string.match(c, "y: ([-%d]+)"))
		collaider.w = tonumber(string.match(c, "w: ([-%d]+)"))
		collaider.h = tonumber(string.match(c, "h: ([-%d]+)"))
		-- загрузка координат коллайдера в массив для нахождения радиуса --
		table.insert(r, math.abs(collaider.x))
		table.insert(r, math.abs(collaider.x + collaider.w))
		table.insert(r, math.abs(collaider.y))
		table.insert(r, math.abs(collaider.y + collaider.h))
	return collaider
end


function CreateEntity(id) -- функция создания экземпляра объекта из списка "sourse_list" и помещение его в память объектов сцены (массив "entity_list")
-------------------------------------

	local created_object = nil -- создаём заготовку для объекта

	for sourse = 1, #sourse_list do -- поиск по id объекта в списке ресурсов
		if sourse_list[sourse].id == id then
			created_object = CopyTable(sourse_list[sourse].en)
		end
	end

	if created_object ~= nil then -- если мы нашли этот объект, выставляем ему начальные значения и добавляем

		created_object.x = 0
		created_object.y = 0
		created_object.z = 0

		created_object.vel_x = 0
		created_object.vel_y = 0
		created_object.vel_z = 0


		created_object.in_air = false

		created_object.facing = 1

		created_object.frame = 1
		created_object.next_frame = 1
		created_object.wait = 0

		created_object.arest = 0
		created_object.vrest = 0

		created_object.key_timer = {
			up = 0,
			down = 0,
			left = 0,
			right = 0,
			attack = 0,
			jump = 0,
			defend = 0,
			jutsu = 0
		}

		created_object.double_key_timer = {
			up = 0,
			down = 0,
			left = 0,
			right = 0,
			attack = 0,
			jump = 0,
			defend = 0,
			jutsu = 0
		}

		created_object.key_pressed = {
			up = 0,
			down = 0,
			left = 0,
			right = 0,
			attack = 0,
			jump = 0,
			defend = 0,
			jutsu = 0
		}

		created_object.dynamic_id = id
		created_object.real_id = id

		for free_id = 1, #entity_list + 1 do
			if (entity_list[free_id] == "nil") or (entity_list[free_id] == nil) then
				created_object.dynamic_id = free_id
				entity_list[free_id] = created_object
				break
			end
		end
		return created_object.dynamic_id
	end
end


function CopyTable (table)
	local result = {}
	for key, val in pairs(table) do
		if type(val) == "table" then
			result[key] = CopyTable(val)
		else
			result[key] = val
		end
	end
	return result
end


function RemoveEntity(en_id)
	if (entity_list[en_id] ~= "nil") and (entity_list[en_id] ~= nil) then
		for key in pairs(entity_list[en_id]) do
			entity_list[en_id][key] = nil
		end
		entity_list[en_id] = "nil"
	end
end