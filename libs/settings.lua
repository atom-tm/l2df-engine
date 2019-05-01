local fs = love.filesystem

local settings = {}

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

	--- Bootstrap game settings, set default values.
	function settings:init()

		self.gamePath = fs.getSourceBaseDirectory()
		fs.mount(self.gamePath, "")

		self.global = {}								-- Таблица с настройками, доступными для изменения пользователем

		self.file = "data/settings.s" 					-- Путь файла настроек игры
		self.global.data = "data/data.c"				-- Путь до data.txt (список объектов и карт движка)
		self.global.frames = "data/frames.c" 			-- Путь до frames.dat (список кадров по умолчанию)
		self.global.combos = "data/combos.c"			-- Путь до combos.dat (список переходов по комбинациям клавиш)
		self.global.dtypes = "data/dtypes.c"			-- Путь до dtypes.dat (список поведения при разных типах урона)
		self.global.system = "data/system.c"

		self.global.roomsFolder 	= "/rooms/" 		-- Папка с файлами комнат
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
			vsync 				= false, 				-- Вертикальная синхронизация
			shadows 			= true, 				-- Детализированные тени
			reflections			= true,					-- Отражения
			smoothing			= true, 				-- Фильтрация текстур
			effects				= true,					-- Количество эффектов и частиц
			details 			= true,					-- Показ необязательных элементов
		}

		self.global.difficulty 		= 2 				-- Сложность игры (от 1 до 3)

		self.global.localization 	= 1 				-- Выбранный файл локализации
		self.global.startRoom 		= "main_menu"		-- Начальная комната
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

	--- Load game settings from settings.file
	function settings:load()
		local settings_data = fs.read(self.file)
		if settings_data then
			local settings_array = json:decode(settings_data)
			for key, val in pairs(settings_array) do
				self.global[key] = val
			end
		end
		self:save()
	end

	--- Save game settings to settings.filefile
	function settings:save()
		local save_string = json:encode_pretty(self.global)
		local settings_file = io.open(fs.getSource() .. "/" .. self.file,"w")
		settings_file:write(save_string)
		settings_file:flush()
		settings_file:close()
	end

	--- Read settings from file
	-- @param filepath, string  Path to settings file
	function settings:Read(filepath)
		local settings_data = fs.read(filepath)
		if settings_data ~= nil then

			self.window.music_vol = helper.PNumber(settings_data, "music_volume", 50)
			self.window.sound_vol = helper.PNumber(settings_data, "sound_volume", 70)
			self.quality = helper.PBool(settings_data, "quality")
			self.window.fullscreen = helper.PBool(settings_data, "fullscreen")
			self.window.selectedSize = helper.PNumber(settings_data, "window_size", 3)
			self.names[1] = helper.PString(settings_data, "player1_name", "")
			self.names[2] = helper.PString(settings_data, "player2_name", "")
			loc.id = helper.PNumber(settings_data, "localization", 1)
			
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
		self.file = filepath
	end

	--- Save settings to settings.file
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