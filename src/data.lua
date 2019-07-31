local core = l2df or require((...):match("(.-)[^%.]+$") .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Data works only with l2df v1.0 and higher")

local datParser = core.import "parsers.dat"

local data = { }

	function data:loadStates(path)
		self.states = helper.requireAllFromFolder(path or core.settings.global.states_path)
		self.states_update = { }
		for key, state in pairs(self.states) do
			if state.update then self.states_update[key] = state end
		end
	end

	function data:loadKinds(path)
		self.kinds = helper.requireAllFromFolder(path or core.settings.global.kinds_path)
	end

	function data:loadFrames(path)
		self.frames = datParser:parseFile(path or core.settings.global.frames_path, self.frames)
	end

	function data:loadSystem(path)
		self.system = datParser:parseFile(path or core.settings.global.system_path, self.system)
	end

	function data:loadCombos(path)
		self.combos = datParser:parseFile(path or core.settings.global.combos_path, self.combos)
	end

	function data:loadDtypes(path)
		self.dtypes = datParser:parseFile(path or core.settings.global.dtypes_path, self.dtypes)
	end

	function data:loadData(path)
		self.list = datParser:parseFile(path or core.settings.global.data_path, self.list)
	end


	--[[


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
			for dtype_number, dtype_info in string.gmatch(dtypes_file, "([%d]+): %[([^%[%") do
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
			local characters = string.match(data_file, "%[characters%]([^%[%]+)")
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

			local objects = string.match(data_file, "%[objects%]([^%[%]+)")
			for id, file in string.gmatch(objects, "id: (%d+)%s+file: ([%w._/]+)") do
				if self.entities[tonumber(id)] == nil then
					self.entities[tonumber(id)] = file
				end
			end

			local maps = string.match(data_file, "%[maps%]([^%[%]+)")
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
	end]]

return data