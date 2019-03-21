local settings = {}
	
	settings.gamePath = love.filesystem.getSourceBaseDirectory() -- берем путь до папки с игрой
	love.filesystem.mount(settings.gamePath, "") -- "Монтируем" нашу игру по указанному пути (для использования внешних файлов)

	local window = {}
		window.fullscreen = nil
		window.music_vol = nil
		window.sound_vol = nil
		window.selectedSize = nil
		window.width = nil
		window.height = nil
		window.cameraScale = nil
		window.realWidth = nil
		window.realHeight = nil
	settings.window = window

	settings.gameWidth = 1280
	settings.gameHeight = 720

	settings.quality = true

	settings.names = {}

	settings.debug_mode = true

	settings.windowSizes = {
		{ width = 854, height = 480 },
		{ width = 1024, height = 576 },
		{ width = 1280, height = 720 },
		{ width = 1366, height = 768 },
		{ width = 1600, height = 900 },
		{ width = 1920, height = 1080 },
	}

	settings.localizationsList = {
		"english",
		"russian"
	}

	settings.controls = {
		{ up = "w", down = "s", left = "a", right = "d", attack = "f", jump = "g", defend = "h", special1 = "j" },
		{ up = "o", down = "l", left = "k", right = ";", attack = "p", jump = "[", defend = "]", special1 = "\\" }
	}

	settings.file = nil

	function settings:Read(settings_file)
		local settings_data = love.filesystem.read(settings_file)
		if settings_data ~= nil then

			self.window.music_vol = get.PNumber(settings_data, "music_volume", 50)
			self.window.sound_vol = get.PNumber(settings_data, "sound_volume", 70)
			self.quality = get.PBool(settings_data, "quality")
			self.window.fullscreen = get.PBool(settings_data, "fullscreen")
			self.window.selectedSize = get.PNumber(settings_data, "window_size", 3)
			self.names[1] = get.PString(settings_data, "player1_name", "")
			self.names[2] = get.PString(settings_data, "player2_name", "")
			loc.id = get.PNumber(settings_data, "localization", 1)
			
			local controls_string = string.match(settings_data, "controls_player_1: {([^{}]+)}")
			if controls_string ~= nil then
				local controls_massive = {}
				for key, key_code in string.gmatch(controls_string, "([%w]+): ([^%s]+)") do
					if key_code == "lsqbr" then key_code = "["
					elseif key_code == "rsqbr" then key_code = "]" end
					settings.controls[1][key] = key_code
				end
			end

			local controls_string = string.match(settings_data, "controls_player_2: {([^{}]+)}")
			if controls_string ~= nil then
				local controls_massive = {}
				for key, key_code in string.gmatch(controls_string, "([%w]+): ([^%s]+)") do
					if key_code == "lsqbr" then key_code = "["
					elseif key_code == "rsqbr" then key_code = "]" end
					settings.controls[2][key] = key_code
				end
			end
		end
		self.file = settings_file
	end



	function settings:Save()
		local settings_file = io.open("../"..self.file,"w+")
		if settings_file ~= nil then

			local controls_player_1 = " "
			for key,key_code in pairs(self.controls[1]) do
				controls_player_1 = controls_player_1..key..": "..key_code.." "
			end
			local controls_player_2 = " "
			for key,key_code in pairs(self.controls[2]) do
				controls_player_2 = controls_player_2..key..": "..key_code.." "
			end

			local save_data = "[settings]".."\n"..
			"music_volume: "..self.window.music_vol.."\n"..
			"sound_volume: "..self.window.sound_vol.."\n"..
			"fullscreen: "..tostring(self.window.fullscreen).."\n"..
			"window_size: "..self.window.selectedSize.."\n"..
			"localization: "..loc.id.."\n"..
			"quality: "..tostring(self.quality).."\n"..
			"controls_player_1: {"..controls_player_1.."}\n"..
			"controls_player_2: {"..controls_player_2.."}\n"..
			"player1_name: "..self.names[1].."\n"..
			"player2_name: "..self.names[2]
			
			settings_file:write(save_data)
			settings_file:flush()
			settings_file:close()
		end
	end

return settings




--[[fonts = {}
fonts.default = love.graphics.newFont("sprites/UI/menu.otf",16)
fonts.menu_head = love.graphics.newFont("sprites/UI/menu.otf",42)
fonts.menu_comment = love.graphics.newFont("sprites/UI/menu.otf",24)
fonts.menu = love.graphics.newFont("sprites/UI/menu.otf",32)

function save_settings()
	local data_file = "data/settings.txt"
	local File = io.open("../"..data_file,"w+")
	if File ~= nil then
		local data_save = "[settings]"
		.."\nmusic_vol: "..window.music_vol
		.."\nsound_vol: "..window.sound_vol
		.."\nwindow_size: "..selected_window_size
		.."\nfullscreen: "..tostring(window.fullscreen)
		.."\nlanguage: "..localization_number
		local controls_string = "controls: {"
		for key1 in ipairs(control_settings) do
			for key2 in pairs(control_settings[key1]) do
				key = control_settings[key1][key2]
				if key == "[" then
					key = "lsqbr"
				elseif key == "]" then
					key = "lsqbr"
				end
				controls_string = controls_string .. key .. " "
			end
		end
		controls_string = controls_string.."}"
		data_save = data_save.."\n"..controls_string
		File:write(data_save)
		File:close()
	end
end

function setWindowSize()
	love.window.setMode( window_sizes[selected_window_size].width, window_sizes[selected_window_size].height )
	camera = CameraCreate()
end

function setFullscreen ()
	love.window.setFullscreen( window.fullscreen )
	camera = CameraCreate()
end]]