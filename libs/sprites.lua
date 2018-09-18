images_list = {} -- таблица в которой хранятся все изображения, подружаемые в память в начале боя. Чтобы не подгружать одни и те же изображения несколько раз для каждого персонажа, они будут загружаться сюда единожды, с помощью специальной функции, а в персонажа будешь лишь отдаваться ссылка на данное изображение


function LoadImage(path) -- функция проверяет наличие указанного изображения в списке загруженных. если изображение уже загружено в память, оно не будет загружено заново, а функция вернёт ссылку на загруженную картинку.
-------------------------------------
	
	local returned_image -- сюда положим возвращаемую картику

	for i in pairs(images_list) do
		if images_list[i].file_path == path then
			returned_image = images_list[i].image
		end
	end -- если такая картинка уже загружена в массив, она будет положена в возвращаемую переменную

	if returned_image == nil then
		returned_image = love.graphics.newImage(path)
		new_image = {
			file_path = path,
			image = returned_image
		}
		table.insert(images_list, new_image)
	end -- если такой картинки ещё нет в массиве, она будет загружена туда и возвращена

	return returned_image
end


function SpriteCutting(w,h,x,y,image) -- нарезка спрайт листа на отдельные изображения. Функия возвращает что-то вроде "масок", которые при отрисовке накладываются на спрайт-лист.
-------------------------------------
	
	local pics = {} -- тут будут лежать все "маски"

	for i = 0, y - 1 do
		for j = 0, x - 1 do
			pics[#pics + 1] = love.graphics.newQuad(w*j, h*i ,w,h, image:getDimensions())
		end
	end -- процесс нарезки
	
	--love.window.showMessageBox( "..", #pics, "info", true)

	return pics -- возвращаем

end


function DrawEntity(en) -- функция рисует объект или персонажа
-------------------------------------
	
	local facing = en.facing
	local frame = en.frames[tostring(en.frame)]

	if not (frame == nil) then

		local x = en.x - Get(frame.centerx) * facing
		local y = en.y - Get(frame.centery)

		local sizex = 1 * facing
		local sizey = 1

		local pic = tonumber(Get(frame.pic))


		if not (pic == 0) then 

		local list
		local sprite
			
			for s = 1, #en.sprites do
				if pic > #en.sprites[s].pics then
					pic = pic - #en.sprites[s].pics
				else
					list = en.sprites[s].file
					sprite = en.sprites[s].pics[pic]
					break
				end
			end

		love.graphics.draw(list, sprite, x, y, 0, sizex, sizey)

		end

			for key, c in pairs(GetCollaiders(en)) do

				if c.type == "itr" then
					love.graphics.setColor(1, 0, 0, 1)
				elseif c.type == "body" then
					love.graphics.setColor(0, 0, 1, 1)
				else
					love.graphics.setColor(1, 1, 1, 1)
				end

				love.graphics.rectangle("line", c.x, c.y, c.w, c.h)
				love.graphics.setColor(1, 1, 1, 1)
				
			end

		love.graphics.setColor(1, 0, 0, 1)
		love.graphics.points(en.x, en.y, en.x-1, en.y, en.x+1, en.y, en.x, en.y+1, en.x, en.y-1)
		love.graphics.setColor(1, 1, 1, 1)

	end
end