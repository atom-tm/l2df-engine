local settings = {}

	local filesystem = love.filesystem

	-- Выделение памяти под настройки игры и установка значений по умолчанию
	function settings:settingsInitialize()
		
		self.gamePath = filesystem.getSourceBaseDirectory()
		filesystem.mount(self.gamePath, "")

		self.global = {}								-- Таблица с настройками, доступными для изменения пользователем

		self.file = "data/settings.conf" 				-- Путь файла настроек игры
		self.global.data = "data/data.txt"				-- Путь до data.txt (список объектов и карт движка)
		self.global.frames = "data/frames.dat" 			-- Путь до frames.dat (список кадров по умолчанию)
		self.global.combos = "data/combos.dat"			-- Путь до combos.dat (список переходов по комбинациям клавиш)
		self.global.dtypes = "data/dtypes.dat"			-- Путь до dtypes.dat (список поведения при разных типах урона)

		self.global.statesFolder 	= "/data/states/"	-- Папка с файлами стейтов
		self.global.kindsFolder 	= "/data/kinds/"	-- Папка с файлами типов взаимодействий
		self.global.localesFolder	= "/data/locales/"	-- Папка с файлами локализаций
		self.global.UIFolder		= "/sprites/UI/"	-- Папка с элементами оформления

		self.resolutions = {							-- Доступные разрешения холста игры
			{ width = 854, height = 480 },					-- 854х480
			{ width = 1024, height = 576 },					-- 1024х576
			{ width = 1280, height = 720 },					-- 1280х720
			{ width = 1366, height = 768 },					-- 1366х768
			{ width = 1600, height = 900 },					-- 1600х900
			{ width = 1920, height = 1080 },				-- 1920х1080
		}

		self.global.resolution 		= 3					-- Текущее разрешение холста
		self.global.gameWidth 		= 1280 				-- Ширина холста игры
		self.global.gameHeight		= 720 				-- Высота холста игры

		self.global.windowWidth		= 1280 				-- Ширина окна игры
		self.global.windowHeight	= 720 				-- Высота окна игры

		self.global.musicVolume 	= 50				-- Громкость музыки
		self.global.soundVolume 	= 100				-- Громкость звука

		self.global.graphic = {							-- Настройки графической составляющей игры
			fullscreen 			= false,				-- Полный экран
			fpsLimit 			= 60,					-- Ограничение FPS
			shadows 			= true, 				-- Детализированные тени
			reflections			= true,					-- Отражения
			smoothing			= true, 				-- Фильтрация текстур
			effects				= true,					-- Количество эффектов и частиц
			details 			= true,					-- Показ необязательных элементов
		}

		self.global.difficulty 		= 2 				-- Сложность игры (от 1 до 3)

		self.global.localization 	= 1 				-- Выбранный файл локализации
		self.global.debug 			= true 				-- Показ отладочной информации

		self.global.controls = {						-- Настройки управления
			{
				name = "Player 1",
				up = "w", down = "s", left = "a", right = "d",
			  	attack = "f", jump = "g", defend = "h",
			  	special1 = "j"
			},
			{
				name = "Player 2",
				up = "o", down = "l", left = "k", right = ";",
			  	attack = "p", jump = "[", defend = "]",
			  	special1 = "\\"
			}
		}
	end

	-- Функция считывания настроек из файла settings.file
	function settings:load()
		local settings_data = filesystem.read(self.file)
		if settings_data then
			self.global = self.readArray(settings_data)
		else
			self:save()
		end
	end

	-- Функция сохранения настроек в файл settings.file
	function settings:save()
		local save_string = settings.writeArray(self.global)
		local settings_file = io.open(filesystem.getSource() .. "/" .. self.file,"w")
		settings_file:write(save_string)
		settings_file:flush()
		settings_file:close()
	end

	-- Функция обрабатывает массив и преобразует его в строку
	-- @param array, table, Массив настроек
	-- @param name, string, Необязательный параметр имени родителя
	-- @return string
	function settings.writeArray(array, name)
		local result = ""
		for key, val in pairs(array) do
			if type(val) == "table" then
				if name then
					result = result .. settings.writeArray(val, name .. "." .. key)
				else
					result = result .. settings.writeArray(val, key)
				end
			else
				local _s
				if name then
					_s = name .. "." .. key .. " = \"" .. tostring(val) .. "\""
				else
					_s = key .. " = \"" .. tostring(val) .. "\""
				end
				result = result .. _s .. "\n"
			end
		end
		return result
	end


	function settings.readArray(string)
		local result = {}
		for key, val in string.gmatch(string,"([^= ]+) = \"([^\"]+)\"") do
			result[key] = val
		end
		return result
	end

	
	


	local window = {}
		window.fullscreen = false
		window.music_vol = 100
		window.sound_vol = 100
		window.selectedSize = 1
		window.width = 1280
		window.height = 720
		window.cameraScale = 0
		window.realWidth = nil
		window.realHeight = nil
	settings.window = window

	settings.gameWidth = 1280
	settings.gameHeight = 720
	settings.fpsLimit = 60

	settings.quality = true
	settings.difficulty = 7

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

	--settings.file = nil

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

			local file = io.open(self.file, "w")
			file:write(save_data)
			file:flush()
			file:close()
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