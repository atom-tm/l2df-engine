data = {}
	data.entities = {}
	data.characters_list = {}
	data.maps_list = {}
	data.maps = {}

	function data:Load (data_file_path)
		local data_file = love.filesystem.read(data_file_path)
		if data_file ~= nil then
			self.file = data_file_path
			local characters = string.match(data_file, "%[characters%]([^%[%]]+)")
			for id, file in string.gmatch(characters, "id: (%d+)%s+file: ([%w._/]+)") do
				if self.entities[tonumber(id)] == nil then
					self.entities[id] = file
					local character_file = love.filesystem.read(file)
					local start_animation = string.match(character_file,"start_animation: {([^{}]*)}")
					local start_animation_cinfo = {
						x = get.PNumber(start_animation,"row"),
						y = get.PNumber(start_animation,"col"),
						w = get.PNumber(start_animation,"w"),
						h = get.PNumber(start_animation,"h")
					}
					local start_standing = string.match(character_file,"start_standing: {([^{}]*)}")
					local start_standing_cinfo = {
						x = get.PNumber(start_standing,"row"),
						y = get.PNumber(start_standing,"col"),
						w = get.PNumber(start_standing,"w"),
						h = get.PNumber(start_standing,"h")
					}
					local character_info = {
						id = id,
						name = get.PString(character_file,"name"),
						head = image.Load(string.match(character_file,"head: \"([^\"\"]+)\"")),
						animation = image.Load(string.match(start_animation, "file: \"(.*)\""), start_animation_cinfo),
						standing = image.Load(string.match(start_standing, "file: \"(.*)\""), start_standing_cinfo)
					}

					character_info.animation.wait = get.PNumber(start_animation,"wait",5)
					character_info.animation.centerx = get.PNumber(start_animation,"centerx",0)
					character_info.animation.centery = get.PNumber(start_animation,"centery",0)

					character_info.standing.wait = get.PNumber(start_standing,"wait",5)
					character_info.standing.centerx = get.PNumber(start_standing,"centerx",0)
					character_info.standing.centery = get.PNumber(start_standing,"centery",0)

					table.insert(self.characters_list,character_info)
				end
			end
			local objects = string.match(data_file, "%[objects%]([^%[%]]+)")
			for id, file in string.gmatch(objects, "id: (%d+)%s+file: ([%w._/]+)") do
				if self.entities[tonumber(id)] == nil then
					self.entities[id] = file
				end
			end
			local maps = string.match(data_file, "%[maps%]([^%[%]]+)")
			for id, file in string.gmatch(maps, "id: (%d+)%s+file: ([%w._/]+)") do
				if self.maps[tonumber(id)] == nil then
					self.maps[id] = file
					local map_file = love.filesystem.read(file)
					local map_info = {
						id = id,
						name = get.PString(map_file,"name"),
						preview = image.Load(string.match(map_file,"preview: \"([^\"\"]+)\""))
					}
					table.insert(self.maps_list,map_info)
				end
			end
		end
	end
return data