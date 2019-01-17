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

		if Etype == nil or Etype == "entity" then
			massive = resourses.loading_list.entities
		elseif Etype == "map" then
			massive = resourses.loading_list.maps
		elseif Etype == "sound" then
			massive = resourses.loading_list.sounds
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
			data = love.filesystem.read(data.entities[Id]),
			stage = 1
		}

		table.insert(massive, object)

		return true

	end

	function resourses.EntityLoading()
		if resourses.pointer == nil or resourses.pointer == 0 then
			resourses.pointer = 1
		elseif resourses.pointer > #resourses.loading_list.entities then
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
		    resourses.pointer = resourses.pointer + 1
		end

		return false
	end

	function resourses.EntityLoadingHeader(object)
		local head = resourses.entities[object.id].head
		local data = string.match(object.data, "<head>(.*)</head>")

		if data ~= nil then
			
			head.name 						= string.match(data, "name: ([%w_% ]+)")
			head.type 						= get.PString(data, "type")

			head.physic 					= get.PBool(data, "physic")
			head.collision 					= get.PBool(data, "collision")
			head.shadow 					= get.PBool(data, "shadow")

			head.str 						= get.PNumber(data, "str")
			head.int 						= get.PNumber(data, "int")
			head.agl 						= get.PNumber(data, "agl")

			head.hp 						= get.PNumber(data, "hp")
			head.mp 						= get.PNumber(data, "mp")
			head.fall 						= get.PNumber(data, "fall")
			head.bdefend 					= get.PNumber(data, "bdefend")

			head.walking_speed_x 			= get.PNumber(data, "walking_speed_x")
			head.walking_speed_z 			= get.PNumber(data, "walking_speed_z")	
			head.running_speed_x 			= get.PNumber(data, "running_speed_x")
			head.running_speed_z 			= get.PNumber(data, "running_speed_z")
			head.jump_height 				= get.PNumber(data, "jump_height")
			head.jump_width 				= get.PNumber(data, "jump_width")
			head.jump_widthz 				= get.PNumber(data, "jump_widthz")
			head.dash_height				= get.PNumber(data, "dash_height")
			head.dash_width 				= get.PNumber(data, "dash_width")
			head.dash_widthz 				= get.PNumber(data, "dash_widthz")

			head.starting_frame 			= get.PNumber(data, "starting_frame") -- приветствие
			head.idle_frame 				= get.PNumber(data, "idle_frame") -- стойка
			head.walking_frames 			= get.PFrames(data, "walking_frames") -- ходьба
			head.running_frames 			= get.PFrames(data, "running_frames") -- бег
			head.running_stop 				= get.PNumber(data, "running_stop") -- остановка после бега
			head.jump_frame 				= get.PNumber(data, "jump_frame") -- прыжок
			head.dash_frame 				= get.PNumber(data, "dash_frame") -- деш
			head.air_frame 					= get.PNumber(data, "air_frame") -- свободное падение
			head.landing_frame 				= get.PNumber(data, "landing_frame") -- приземление
			head.rowing 					= get.PNumber(data, "rowing") -- подкат
			head.attack_frames 				= get.PFrames(data, "attack_frames") -- удары
			head.run_attack_frame 			= get.PNumber(data, "run_attack_frame") -- удар на бегу
			head.jump_attack_frame 			= get.PNumber(data, "jump_attack_frame") -- удар в прыжке
			head.dash_attack_frame 			= get.PNumber(data, "dash_attack_frame") -- удар в деше
			head.defend_frame 				= get.PNumber(data, "defend_frame") -- защита

			return true
		else
			return false
		end
	end

	function resourses.EntityLoadingSprites(object)
		local sprites = resourses.entities[object.id].sprites
		local head = resourses.entities[object.id].head
		local data = string.match(object.data, "<head>(.*)</head>")

		if data ~= nil then
			local pics_counter = 0
			
			for sprite_info in string.gmatch(data, "sprite: {([^{}]*)}") do
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
				pics_counter = pics_counter + #sprite.file.sprites
				sprite.pics = pics_counter

				table.insert(sprites, sprite)
			end
			sprites.count = pics_counter
			return true
		else
			return false
		end
	end


	function resourses.EntityLoadFrames(object)
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

	function resourses.LoadFrame(data)
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

		frame.hit_f 					= get.PNumber(header,"hit_f")
		frame.hit_b 					= get.PNumber(header,"hit_b")
		frame.hit_w 					= get.PNumber(header,"hit_w")
		frame.hit_s 					= get.PNumber(header,"hit_s")

		frame.hit_df 					= get.PNumber(header,"hit_df")
		frame.hit_db 					= get.PNumber(header,"hit_db")
		frame.hit_dw 					= get.PNumber(header,"hit_dw")
		frame.hit_ds 					= get.PNumber(header,"hit_ds")

		return frame
	end

return resourses