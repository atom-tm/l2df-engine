local resourses = {}
	
	resourses.entities = {}
	resourses.maps = {}
	resourses.sounds = {}

	resourses.loading_list = {
		entities = {},
		maps = {},
		sounds = {}
	}

	function resourses.Clear()
		resourses.loading_list = {
			entities = {},
			maps = {},
			sounds = {}
		}
		resourses.entities = {}
		resourses.maps = {}
		resourses.sounds = {}
		resourses.pointer = 0
		collectgarbage()
	end

	function resourses.AddToLoading(Id, Etype)
		local massive = nil
		local data_sourse = nil

		if Etype == nil or Etype == "entity" then
			massive = resourses.loading_list.entities
			data_sourse = data.entities
		elseif Etype == "map" then
			massive = resourses.loading_list.maps
			data_sourse = data.maps
		else
		    return false
		end

		for i = 1, #massive do
			if massive[i].id == Id then
				return true
			end
		end

		local object = {
			id = Id,
			data = love.filesystem.read(data_sourse[Id]),
			stage = 1
		}

		table.insert(massive, object)

		return true

	end











	function resourses.EntityLoading() -- Поэтапная загрузка объекта
	----------------------------------------------------------------------------
		if resourses.pointer == nil or resourses.pointer == 0 then
			resourses.pointer = 1
		elseif resourses.pointer > #resourses.loading_list.entities then
			resourses.pointer = 0
			return true
		end

		local object = resourses.loading_list.entities[resourses.pointer]

		if object.stage == 1 then
			local entity = {
				head = {},
				sprites = {},
				damages = {},
				frames = {},
				variables = {},
				scripts = {}
			}
			resourses.entities[object.id] = entity
			object.stage = 2
		elseif object.stage == 2 then
			if resourses.EntityLoadingHeader(object) then
				object.stage = 3
			end
		elseif object.stage == 3 then
			if resourses.EntityLoadingSprites(object) then
				object.stage = 4
			end
		elseif object.stage == 4 then
		    if resourses.EntityLoadFrames(object) then
				object.stage = 5
			end
		elseif object.stage == 5 then
		    if resourses.EntityLoadingFramesList(object) then
				if resourses.EntityLoadingDtypes(object) then
					if resourses.EntityLoadingOther(object) then
						object.stage = 6
					end
				end
			end
		elseif object.stage == 6 then
		    resourses.pointer = resourses.pointer + 1
		end

		return false
	end










	function resourses.EntityLoadingHeader(object) -- Загрузка шапки объекта
	----------------------------------------------------------------------------
		local head = resourses.entities[object.id].head
		local data = string.match(object.data, "<head>(.*)</head>")

		if data ~= nil then
			
			head.name 						= string.match(data, "name: ([%w_% ]+)")
			head.type 						= get.PString(data, "type")

			head.gravity 					= get.PBool(data, "gravity")
			head.collision 					= get.PBool(data, "collision")
			head.shadow 					= get.PBool(data, "shadow")
			head.nextZero 					= not get.PBool(data, "nextZero")

			head.str 						= get.PNumber(data, "str")
			head.int 						= get.PNumber(data, "int")
			head.agl 						= get.PNumber(data, "agl")

			head.hp 						= get.PNumber(data, "hp",1000)
			head.mp 						= get.PNumber(data, "mp",500)
			head.fall 						= get.PNumber(data, "fall",70)
			head.bdefend 					= get.PNumber(data, "bdefend",60)

			head.states						= get.PFramesString(data, "states")

			return true
		else
			return false
		end
	end


	function resourses.EntityLoadingFramesList(object) -- Загрузка шапки объекта
	----------------------------------------------------------------------------
		local head = resourses.entities[object.id].head
		head.frames = func.CopyTable(data.frames)
		local data = string.match(object.data, "<frames_list>(.*)</frames_list>")
		if data ~= nil then
			for key, frame_number in string.gmatch(data, "([%w%d_]+): ([%d]+)") do
				head.frames[key] = tonumber(frame_number)
			end
			for key, frames_array in string.gmatch(data, "([%w%d_]+): ({[%d, ]+})") do
				local array = {}
				for frame_number in string.gmatch(frames_array, "([%d]+)") do
					table.insert(array, tonumber(frame_number))
				end
				head.frames[key] = array
			end
		end
		return true
	end


	function resourses.EntityLoadingDtypes(object) -- Загрузка шапки объекта
	----------------------------------------------------------------------------
		local head = resourses.entities[object.id].head
		head.dtypes = func.CopyTable(data.dtypes)
		local data = string.match(object.data, "<damage_types>(.*)</damage_types>")
		if data ~= nil then
			for dtype_number, dtype_info in string.gmatch(data, "([%d]+): %[([^%[%]]+)%]") do
				if head.dtypes[dtype_number] == nil then head.dtypes[dtype_number] = {} end
				for key, info in string.gmatch(dtype_info, "([%w%d_]+): ([-%d%.]+)") do
					head.dtypes[dtype_number][key] = tonumber(info)
				end
				for key, info in string.gmatch(dtype_info, "([%w%d_]+): ({[%d, ]+})") do
					local array = {}
					for frame in string.gmatch(info, "([%d]+)") do
						table.insert(array, tonumber(frame))
					end
					head.dtypes[dtype_number][key] = array
				end
			end
		end
		return true
	end




	function resourses.EntityLoadingOther(object) -- Загрузка шапки объекта
	----------------------------------------------------------------------------
		local head = resourses.entities[object.id].head
		
		if head.frames["walking"] ~= nil and type(head.frames["walking"]) == "table" then head.walking_frames = #head.frames["walking"]
		elseif data.frames["walking"] ~= nil and type(data.frames["walking"]) == "table" then head.walking_frames = #data.frames["walking"]
		else head.walking_frames = 0 end	

		if head.frames["running"] ~= nil and type(head.frames["running"]) == "table" then head.running_frames = #head.frames["running"]
		elseif data.frames["running"] ~= nil and type(data.frames["running"]) == "table" then head.running_frames = #data.frames["running"]
		else head.running_frames = 0 end

		resourses.entities[object.id].variables.states = {}
		for key in pairs(data.states) do
			resourses.entities[object.id].variables.states[key] = {}
			if data.states[key].Load ~= nil then
				data.states[key].variables = resourses.entities[object.id].variables.states[key]
				data.states[key]:Load(resourses.entities[object.id])
			end
		end

		return true
	end



	function resourses.EntityLoadingSprites(object) -- Поочередная загрузка спрайтов объекта
	----------------------------------------------------------------------------

		local sprites = resourses.entities[object.id].sprites
		local data = string.match(object.data, "<head>(.*)</head>")

		if data ~= nil then

			if object.sprites == nil or object.current_sprite == nil then
				object.sprites = {}
				object.current_sprite = 1
				sprites.count = 0
				for sprite in string.gmatch(data, "sprite: {([^{}]*)}") do
					table.insert(object.sprites,sprite)
				end
				return false
			else
				for i = 1, 1 do
					if object.current_sprite > #object.sprites then
						return true
					else
						local sprite_info = object.sprites[object.current_sprite]

						local file_path = string.match(sprite_info, "file: \"(.*)\"")
						local cutting_info = {
							w = get.PNumber(sprite_info, "w"),
							h = get.PNumber(sprite_info, "h"),
							x = get.PNumber(sprite_info, "row"),
							y = get.PNumber(sprite_info, "col"),
						}
						local filter = "nearest"
						if get.PBool(sprite_info, "fsaa") then filter = "linear" end

						local sprite = {}
						sprite.file = image.Load(file_path,cutting_info,filter)
						sprites.count = sprites.count + #sprite.file.sprites

						table.insert(sprites, sprite)
						object.current_sprite = object.current_sprite + 1
					end
				end
				return false
			end
		else
		    return false
		end
	end





	function resourses.EntityLoadFrames(object) -- Поочередная загрузка фреймов объекта
	----------------------------------------------------------------------------
		if object.frames == nil or object.current_frame == nil then
			object.frames = {}
			object.current_frame = 1
			for frame in string.gmatch(object.data, "<frame>([^<>]*)</frame>") do
				table.insert(object.frames,frame)
			end
			return false
		else
			for i = 1, 10 do
				if object.current_frame > #object.frames then
					return true
				else
					local data = object.frames[object.current_frame]
					local frame = resourses.LoadFrame(data)
					local frame_number = tonumber(string.match(data, "(%d+)"))
					resourses.entities[object.id].frames[frame_number] = frame
					object.current_frame = object.current_frame + 1
				end
			end
			return false
		end
	end






	function resourses.LoadFrame(data) -- Загрузка фрейма объекта
	----------------------------------------------------------------------------
		local frame = {}
		local header = string.match(data, "([^{}]+)")

		frame.pic 						= get.PNumber(header,"pic")
		frame.next 						= get.PNumber(header,"next")
		frame.wait 						= get.PNumber(header,"wait")
		frame.centerx 					= get.PNumber(header,"centerx")
		frame.centery 					= get.PNumber(header,"centery")

		frame.shadow 					= not get.PBool(header,"shadow")
		frame.zoom 						= get.PNumber(header,"zoom",1)

		frame.dvx 						= get.PNumber(header,"dvx")
		frame.dsx 						= get.PNumber(header,"dsx")
		frame.dx 						= get.PNumber(header,"dx")

		frame.dvy 						= get.PNumber(header,"dvy")
		frame.dsy 						= get.PNumber(header,"dsy")
		frame.dy 						= get.PNumber(header,"dy")

		frame.dvz 						= get.PNumber(header,"dvz")
		frame.dsz 						= get.PNumber(header,"dsz")
		frame.dz 						= get.PNumber(header,"dz")

		frame.hit_Ua 					= get.PNumber(header,"hit_Ua")
		frame.hit_Uj 					= get.PNumber(header,"hit_Uj")
		frame.hit_Da 					= get.PNumber(header,"hit_Da")
		frame.hit_Dj 					= get.PNumber(header,"hit_Dj")
		frame.hit_Fa 					= get.PNumber(header,"hit_Fa")
		frame.hit_Fj 					= get.PNumber(header,"hit_Fj")

		frame.hit_a 					= get.PNumber(header,"hit_a")
		frame.hit_j 					= get.PNumber(header,"hit_j")
		frame.hit_d 					= get.PNumber(header,"hit_d")
		frame.hit_sp 					= get.PNumber(header,"hit_sp")

		frame.hit_w 					= get.PNumber(header,"hit_w")
		frame.hit_s 					= get.PNumber(header,"hit_s")
		frame.hit_f 					= get.PNumber(header,"hit_f")
		frame.hit_b						= get.PNumber(header,"hit_b")

		frame.hit_aa 					= get.PNumber(header,"hit_aa")
		frame.hit_jj 					= get.PNumber(header,"hit_jj")
		frame.hit_dd 					= get.PNumber(header,"hit_dd")
		frame.hit_spsp 					= get.PNumber(header,"hit_spsp")
		frame.hit_ww 					= get.PNumber(header,"hit_ww")
		frame.hit_ss 					= get.PNumber(header,"hit_ss")
		frame.hit_ff 					= get.PNumber(header,"hit_ff")
		frame.hit_bb					= get.PNumber(header,"hit_bb")

		frame.grounded					= get.PNumber(header,"grounded")

		frame.states 					= resourses.LoadStates(data)
		frame.itrs	 					= resourses.LoadItrs(data)
		frame.bodys 					= resourses.LoadBodys(data)
		frame.opoints 					= resourses.LoadOpoints(data)

		return frame
	end






	function resourses.LoadBodys(data) -- Загрузка коллайдеров тела объекта
	----------------------------------------------------------------------------
		local bodys = {}
		local bodys_radiuses_x = {}
		local bodys_radiuses_y = {}
		local bodys_radiuses_z = {}

		for body_data in string.gmatch(data, "body: {([^{}]*)}") do
			local body = {}
			
			body.x 							= get.PNumber(body_data,"x",0)
			body.y 							= get.PNumber(body_data,"y",0)
			body.z 							= get.PNumber(body_data,"z",-5)
			
			body.w 							= get.PNumber(body_data,"w",0)
			body.h 							= get.PNumber(body_data,"h",0)
			body.l 							= get.PNumber(body_data,"l",10)


			body.static 					= get.PBool(body_data,"static")
			body.participle 				= get.PBool(body_data,"participle")
			body.damaged_frame 				= get.PNumber(body_data,"damaged_frame")

			body.x_rad 						= get.Biggest(math.abs(body.x),math.abs(body.x + body.w))
			body.y_rad 						= get.Biggest(math.abs(body.y),math.abs(body.y + body.h))
			body.z_rad 						= get.Biggest(math.abs(body.z),math.abs(body.z + body.l))

			table.insert(bodys_radiuses_x, body.x_rad)
			table.insert(bodys_radiuses_y, body.y_rad)
			table.insert(bodys_radiuses_z, body.z_rad)
			table.insert(bodys, body)
		end
		bodys.radius_x = get.Maximum(bodys_radiuses_x)
		bodys.radius_y = get.Maximum(bodys_radiuses_y)
		bodys.radius_z = get.Maximum(bodys_radiuses_z)
		return bodys
	end






	function resourses.LoadItrs(data) -- Загрузка коллайдеров атаки объекта
	----------------------------------------------------------------------------
		local itrs = {}
		local itrs_radiuses_x = {}
		local itrs_radiuses_y = {}
		local itrs_radiuses_z = {}

		for itr_data in string.gmatch(data, "itr: {([^{}]*)}") do
			local itr = {}

			itr.kind 						= get.PNumber(itr_data,"kind")
			itr.dtype 						= get.PNumber(itr_data,"dtype")

			itr.dvx 						= get.PNumber(itr_data,"dvx")
			itr.dvy 						= get.PNumber(itr_data,"dvy")
			itr.dvz 						= get.PNumber(itr_data,"dvz")
			itr.y_repulsion 				= get.PBool(itr_data,"y_repulsion")
			itr.x_repulsion 				= get.PBool(itr_data,"x_repulsion")
			itr.reflection 					= get.PBool(itr_data,"reflection")
			itr.static 						= get.PBool(itr_data,"static")

			itr.injury 						= get.PNumber(itr_data,"injury")
			itr.bdefend 					= get.PNumber(itr_data,"bdefend")
			itr.fall 						= get.PNumber(itr_data,"fall")
			itr.arest						= get.PNumber(itr_data,"arest",10)
			itr.vrest 						= get.PNumber(itr_data,"vrest",15)
			itr.purpose						= get.PNumber(itr_data,"purpose",1)

			itr.not_knocking_down 			= get.PBool(itr_data,"not_knocking_down")

			itr.attacker_frame 				= get.PNumber(itr_data,"attacker_frame")
			itr.damaged_frame 				= get.PNumber(itr_data,"damaged_frame")

			itr.x 							= get.PNumber(itr_data,"x",0)
			itr.y 							= get.PNumber(itr_data,"y",0)
			itr.z 							= get.PNumber(itr_data,"z",-5)
			
			itr.w 							= get.PNumber(itr_data,"w",0)
			itr.h 							= get.PNumber(itr_data,"h",0)
			itr.l 							= get.PNumber(itr_data,"l",10)

			itr.x_rad 						= get.Biggest(math.abs(itr.x),math.abs(itr.x + itr.w))
			itr.y_rad 						= get.Biggest(math.abs(itr.y),math.abs(itr.y + itr.h))
			itr.z_rad 						= get.Biggest(math.abs(itr.z),math.abs(itr.z + itr.l))

			table.insert(itrs_radiuses_x, itr.x_rad)
			table.insert(itrs_radiuses_y, itr.y_rad)
			table.insert(itrs_radiuses_z, itr.z_rad)
			table.insert(itrs, itr)
		end
		itrs.radius_x = get.Maximum(itrs_radiuses_x)
		itrs.radius_y = get.Maximum(itrs_radiuses_y)
		itrs.radius_z = get.Maximum(itrs_radiuses_z)
		return itrs
	end







	function resourses.LoadOpoints(data) -- Загрузка блока вызова объекта
	----------------------------------------------------------------------------
		local opoints = {}

		for opoint_data in string.gmatch(data, "opoint: {([^{}]*)}") do
			local opoint = {}

			opoint.id 						= get.PNumber(opoint_data, "id")
			opoint.action 					= get.PNumber(opoint_data, "action")
			opoint.action_random 			= get.PNumber(opoint_data, "raction")
			
			opoint.count 					= get.PNumber(opoint_data, "count",1)
			opoint.count_random				= get.PNumber(opoint_data, "rcount")

			opoint.x 						= get.PNumber(opoint_data, "x")
			opoint.y 						= get.PNumber(opoint_data, "y")
			opoint.z 						= get.PNumber(opoint_data, "z")

			opoint.x_random 				= get.PNumber(opoint_data, "rx")
			opoint.y_random 				= get.PNumber(opoint_data, "ry")
			opoint.z_random 				= get.PNumber(opoint_data, "rz")

			opoint.dvx						= get.PNumber(opoint_data, "dvx")
			opoint.dvy						= get.PNumber(opoint_data, "dvy")
			opoint.dvz						= get.PNumber(opoint_data, "dvz")

			opoint.dvx_random				= get.PNumber(opoint_data, "rdvx")
			opoint.dvy_random				= get.PNumber(opoint_data, "rdvy")
			opoint.dvz_random				= get.PNumber(opoint_data, "rdvz")

			opoint.facing 					= get.PNumber(opoint_data, "facing",1)
			
			table.insert(opoints, opoint)
			resourses.AddToLoading(opoint.id, "entity")
		end

		return opoints
	end







	function resourses.LoadStates(data) -- Загрузка стейтов объекта
	----------------------------------------------------------------------------
		local states = {}
		for state_number, state_data in string.gmatch(data, "state: (%d+) {([^{}]*)}") do
			local state = {}
			state.number = state_number
			for key, val in string.gmatch(state_data, "([%w_]+): ([%w_]+)") do
				if val == "true" then state[key] = true
				elseif val == "false" then state[key] = false
				else state[key] = tostring(val) end
			end
			for key, val in string.gmatch(state_data, "([%w_]+): ([-%d%.]+)") do
				state[key] = tonumber(val)
			end
			table.insert(states, state)
		end
		return states
	end








function resourses.MapLoading() -- Поэтапная загрузка карты
	----------------------------------------------------------------------------
		if resourses.pointer == nil or resourses.pointer == 0 then
			resourses.pointer = 1
		elseif resourses.pointer > #resourses.loading_list.maps then
			return true
		end

		local object = resourses.loading_list.maps[resourses.pointer]

		if object.stage == 1 then
			local map = {
				head = {},
				layers = {},
				filters = {},
				spawn_points = {}
			}
			resourses.maps[object.id] = map
			object.stage = 2
		elseif object.stage == 2 then
			if resourses.MapLoadingHeader(object) then
				object.stage = 3
			end
		elseif object.stage == 3 then
			if resourses.MapLoadLayers(object) then
				object.stage = 4
			end
		elseif object.stage == 4 then
			if resourses.MapLoadFilters(object) then
				object.stage = 5
			end
		elseif object.stage == 5 then
			resourses.pointer = resourses.pointer + 1
		end

		return false
	end






function resourses.MapLoadingHeader(object) -- Загрузка шапки карты
	----------------------------------------------------------------------------
		local map = resourses.maps[object.id]
		local head = map.head
		local data = object.data

		if data ~= nil then

			head.name 						= get.PString(data, "name")
			head.width 						= get.PNumber(data, "width")
			head.height 					= get.PNumber(data, "height")
			head.friction 					= get.PNumber(data, "friction")
			head.gravity 					= get.PNumber(data, "gravity")

			head.reflection 				= get.PBool(data, "reflection")
			head.reflection_opacity 		= get.PNumber(data, "reflection_opacity")

			head.shadow 					= get.PBool(data, "shadow")
			head.shadow_centerx 			= get.PNumber(data, "shadow_centerx")
			head.shadow_opacity 			= get.PNumber(data, "shadow_opacity")
			head.shadow_direction 			= get.PNumber(data, "shadow_direction")
			head.shadow_shear 				= get.PNumber(data, "shadow_shear")
			head.shadow_size 				= get.PNumber(data, "shadow_size")

			head.start_anim 				= get.PBool(data, "start_anim")

			head.border_up 					= get.PNumber(data, "border_up")
			head.border_down 				= get.PNumber(data, "border_down")

			head.objects_stock				= get.PNumber(data, "objects_stock", 15)

			head.area 						= math.abs(head.border_down - head.border_up)
			head.z_center 					= (head.border_up + head.border_down) * 0.5

			map.spawn_points = {}
			for spawn_point_data in string.gmatch(data, "spawn_point: {([^{}]*)}") do
				local spawn_point = {}
				spawn_point.x 			= get.PNumber(spawn_point_data, "x")
				spawn_point.y 			= get.PNumber(spawn_point_data, "y")
				spawn_point.z 			= get.PNumber(spawn_point_data, "z")
				spawn_point.rx 			= get.PNumber(spawn_point_data, "rx")
				spawn_point.ry 			= get.PNumber(spawn_point_data, "ry")
				spawn_point.rz 			= get.PNumber(spawn_point_data, "rz")
				spawn_point.facing 		= get.PNumber(spawn_point_data, "facing")
				table.insert(map.spawn_points, spawn_point)
			end

			return true
		else
			return false
		end
	end




	function resourses.MapLoadLayers(object) -- Поочередная загрузка слоёв карты
	----------------------------------------------------------------------------
		if object.layers == nil or object.current_layer == nil then
			object.layers = {}
			object.current_layer = 1
			for layer in string.gmatch(object.data, "layer: {([^{}]*)}") do
				table.insert(object.layers,layer)
			end
			return false
		else
			for i = 1, 1 do
				if object.current_layer > #object.layers then
					return true
				else
					local data = object.layers[object.current_layer]
					local layer = {}

					local file_path = string.match(data, "file: \"(.*)\"") -- путь до файла слоя
					local filter = "nearest"
					if get.PBool(data, "fsaa") then filter = "linear" end

					layer.sprite 			= image.Load(file_path, nil, filter)

					layer.x 				= get.PNumber(data, "x")
					layer.y 				= get.PNumber(data, "y")

					table.insert(resourses.maps[object.id].layers, layer)
					object.current_layer = object.current_layer + 1
				end
			end
			return false
		end
	end






	function resourses.MapLoadFilters(object) -- Поочередная загрузка слоёв карты
	----------------------------------------------------------------------------
		if object.filters == nil or object.current_filter == nil then
			object.filters = {}
			object.current_filter = 1
			for filter in string.gmatch(object.data, "filter: {([^{}]*)}") do
				table.insert(object.filters,filter)
			end
			return false
		else
			for i = 1, 1 do
				if object.current_filter > #object.filters then
					return true
				else
					local data = object.filters[object.current_filter]
					local filter = {}

					local file_path = string.match(data, "file: \"(.*)\"") -- путь до файла слоя
					local fsaa = "nearest"
					if get.PBool(data, "fsaa") then fsaa = "linear" end

					filter.sprite 			= image.Load(file_path, nil, fsaa)

					filter.x 				= get.PNumber(data, "x")
					filter.y 				= get.PNumber(data, "y")

					table.insert(resourses.maps[object.id].filters, filter)
					object.current_filter = object.current_filter + 1
				end
			end
			return false
		end
	end






return resourses