data = {}

	data.entities = {}
	data.characters_list = {}
	data.maps_list = {}
	data.maps = {}
	data.frames = {}
	data.dtypes = {}
	data.states = {}
	data.states_update = {}
	data.system = {}
	data.kinds = {}

	function data:initialize()
		self.characters = {}
		self.objects = {}
		self.maps = {}
		
	end

	function data:States(dirPath)
		self.states = {}
		local states_list = love.filesystem.getDirectoryItems(dirPath)
		for i = 1, #states_list do
			local state_number = string.gsub(states_list[i], ".lua", "")
			if state_number ~= nil and tonumber(state_number) then
				self.states[state_number] = require(dirPath .. "." .. state_number)
				if self.states[state_number].Update ~= nil then
					data.states_update[state_number] = data.states[state_number]
				end
			end
		end
	end


	function data:Kinds(dirPath)
		self.kinds = {}
		local itrs_list = love.filesystem.getDirectoryItems(dirPath)
		for i = 1, #itrs_list do
			local kind_number = string.gsub(itrs_list[i], ".lua", "")
			if kind_number ~= nil and tonumber(kind_number) then
				self.kinds[tonumber(kind_number)] = require(dirPath .. "." .. kind_number)
			end
		end
	end


	function data:System(filePath)
		data.system = {}
		local system_file = love.filesystem.read(filePath)
		if system_file ~= nil then
			for key, id in string.gmatch(system_file, "([%w%d_]+): ([%d]+)") do
				data.system[key] = tonumber(id)
			end
		end
	end


	function data:Frames(filePath)
		local frames_file = love.filesystem.read(filePath)
		if frames_file ~= nil then
			for key, frame_number in string.gmatch(frames_file, "([%w%d_]+): ([%d]+)") do
				data.frames[key] = tonumber(frame_number)
			end

			for key, frames_array in string.gmatch(frames_file, "([%w%d_]+): ({[%d, ]+})") do
				local array = {}
				for frame_number in string.gmatch(frames_array, "([%d]+)") do
					table.insert(array, tonumber(frame_number))
				end
				data.frames[key] = array
			end
		end
	end


	function data:DTypes(filePath)
		data.dtypes = {}
		local dtypes_file = love.filesystem.read(filePath)
		if dtypes_file then
			for dtype_number, dtype_info in string.gmatch(dtypes_file, "([%d]+): %[([^%[%]]+)%]") do
				local damage_type = {}
				for key, info in string.gmatch(dtype_info, "([%w%d_]+): ([-%d%.]+)") do
					damage_type[key] = tonumber(info)
				end
				for key, info in string.gmatch(dtype_info, "([%w%d_]+): ({[%d, ]+})") do
					local array = {}
					for frame in string.gmatch(info, "([%d]+)") do
						table.insert(array, tonumber(frame))
					end
					damage_type[key] = array
				end
				damage_type.Get = helper.getDamageInfo
				data.dtypes[dtype_number] = damage_type
			end
		end
	end


	function data:Load(filePath)
		local data_file = love.filesystem.read(filePath)
		if data_file ~= nil then
			self.file = filePath
			local characters = string.match(data_file, "%[characters%]([^%[%]]+)")
			for id, file in string.gmatch(characters, "id: (%d+)%s+file: ([%w._/]+)") do
				if self.entities[tonumber(id)] == nil then
					self.entities[tonumber(id)] = file
					local character_file = love.filesystem.read(file)
					local start_animation = string.match(character_file, "start_animation: {([^{}]*)}")
					local start_animation_cinfo = {
						x = helper.PNumber(start_animation, "row"),
						y = helper.PNumber(start_animation, "col"),
						w = helper.PNumber(start_animation, "w"),
						h = helper.PNumber(start_animation, "h")
					}
					local start_standing = string.match(character_file, "start_standing: {([^{}]*)}")
					local start_standing_cinfo = {
						x = helper.PNumber(start_standing, "row"),
						y = helper.PNumber(start_standing, "col"),
						w = helper.PNumber(start_standing, "w"),
						h = helper.PNumber(start_standing, "h")
					}
					local character_info = {
						id = tonumber(id),
						name = helper.PString(character_file, "name"),
						head = image.Load(string.match(character_file, "head: \"([^\"\"]+)\"")),
						animation = image.Load(string.match(start_animation, "file: \"(.*)\""), start_animation_cinfo),
						standing = image.Load(string.match(start_standing, "file: \"(.*)\""), start_standing_cinfo)
					}

					character_info.animation.wait = helper.PNumber(start_animation, "wait", 5)
					character_info.animation.frames = helper.PNumber(start_animation, "frames", start_animation_cinfo.x * start_animation_cinfo.y)
					character_info.animation.centerx = helper.PNumber(start_animation, "centerx", 0)
					character_info.animation.centery = helper.PNumber(start_animation,"centery", 0)

					character_info.standing.wait = helper.PNumber(start_standing, "wait", 5)
					character_info.standing.frames = helper.PNumber(start_standing, "frames", start_standing_cinfo.x * start_standing_cinfo.y)
					character_info.standing.centerx = helper.PNumber(start_standing, "centerx", 0)
					character_info.standing.centery = helper.PNumber(start_standing, "centery", 0)

					table.insert(self.characters_list,character_info)
				end
			end

			local objects = string.match(data_file, "%[objects%]([^%[%]]+)")
			for id, file in string.gmatch(objects, "id: (%d+)%s+file: ([%w._/]+)") do
				if self.entities[tonumber(id)] == nil then
					self.entities[tonumber(id)] = file
				end
			end

			local maps = string.match(data_file, "%[maps%]([^%[%]]+)")
			for id, file in string.gmatch(maps, "id: (%d+)%s+file: ([%w._/]+)") do
				if self.maps[tonumber(id)] == nil then
					self.maps[tonumber(id)] = file
					local map_file = love.filesystem.read(file)
					local map_info = {
						id = tonumber(id),
						name = helper.PString(map_file, "name"),
						preview_0 = image.Load(string.match(map_file, "preview_0: \"([^\"\"]+)\"")),
						preview_1 = image.Load(string.match(map_file, "preview_1: \"([^\"\"]+)\""))
					}
					table.insert(self.maps_list,map_info)
				end
			end
		end
	end

return data