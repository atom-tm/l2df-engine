local core = l2df
assert(type(core) == "table" and core.version <= 1.0, "Settings works only with love2d-fighting v1.0 and less")

local fs = love and love.filesystem
assert(fs, "Settings works only under love2d's environment")

local datParser = core.import "parsers.dat"

local settings = { }

	settings.gamePath = fs.getSourceBaseDirectory()
	fs.mount(settings.gamePath, "")

	settings.global = { }
	settings.private = { }

	settings.file = filepath or "data/settings.dat"		-- Путь файла настроек игры
	settings.global.data_path = "data/data.txt"			-- Путь до data.txt (список объектов и карт движка)
	settings.global.frames_path = "data/frames.dat"		-- Путь до frames.dat (список кадров по умолчанию)
	settings.global.combos_path = "data/combos.dat"		-- Путь до combos.dat (список переходов по комбинациям клавиш)
	settings.global.dtypes_path = "data/dtypes.dat"		-- Путь до dtypes.dat (список поведения при разных типах урона)
	settings.global.system_path = "data/system.dat"		-- Путь до system.dat
	settings.global.fonts_path = "data/fonts.json"		-- Путь до fonts.json (список шрифтов используемых в игре)
	settings.global.rooms_path = "/rooms/"				-- Папка с файлами комнат
	settings.global.states_path = "/data/states/"		-- Папка с файлами стейтов
	settings.global.kinds_path = "/data/kinds/"			-- Папка с файлами типов взаимодействий
	settings.global.langs_path = "/data/langs"			-- Папка с файлами локализаций
	settings.global.ui_path = "/sprites/UI/"			-- Папка с элементами оформления

	settings.private.resolutions = {					-- Доступные разрешения холста игры
		{ width = 854, height = 480 },					-- 854х480
		{ width = 1024, height = 576 },					-- 1024х576
		{ width = 1280, height = 720 },					-- 1280х720
		{ width = 1366, height = 768 },					-- 1366х768
		{ width = 1600, height = 900 },					-- 1600х900
		{ width = 1920, height = 1080 },				-- 1920х1080
	}

	settings.global.resolution = 3						-- Текущее разрешение холста
	settings.gameWidth = 0 								-- Ширина холста игры
	settings.gameHeight = 0 							-- Высота холста игры

	settings.global.width = 854 						-- Ширина окна игры
	settings.global.height = 480 						-- Высота окна игры

	settings.global.music_volume = 50					-- Громкость музыки
	settings.global.sound_volume = 100					-- Громкость звука

	settings.global.difficulty = 2 						-- Сложность игры (от 1 до 3)

	settings.global.lang = "en"							-- Язык локализации
	settings.global.startRoom = "game_start"			-- Начальная комната
	settings.global.debug = true						-- Показ отладочной информации

	settings.graphic = {								-- Настройки графической составляющей игры
		fullscreen = false,								-- Полный экран
		fpsLimit = 60,									-- Ограничение FPS
		vsync = false,									-- Вертикальная синхронизация
		shadows = true,									-- Детализированные тени
		reflections = true,								-- Отражения
		smoothing = true,								-- Фильтрация текстур
		effects = true,									-- Количество эффектов и частиц
		details = true,									-- Показ необязательных элементов
	}

	settings.controls = {								-- Настройки управления
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

	--- Load game settings from settings.file
	function settings:load()
		datParser:parseFile(self.file, self)
		self:save()
	end

	--- Save game settings to settings.file
	function settings:save()
		datParser:dumpToFile(self.file, self)
	end

	--- Apply game settings
	function settings:apply()
		math.randomseed(love.timer.getTime())
		love.graphics.setDefaultFilter("nearest", "nearest")

		self.gameWidth = self.private.resolutions[self.global.resolution].width
		self.gameHeight = self.private.resolutions[self.global.resolution].height

		love.window.setMode(self.gameWidth, self.gameHeight, {
				fullscreen = self.graphic.fullscreen,
				vsync = self.graphic.vsync,
				msaa = 0,
				depth = 0,
				minwidth = self.private.resolutions[1].width,
				minheight = self.private.resolutions[1].height,
				resizable = true
			})

		if self.graphic.fullscreen then
			self.global.width, self.global.height = love.window.getMode()
		else
			self.global.width, self.global.height = self.gameWidth, self.gameHeight
			love.resize(self.gameWidth, self.gameHeight)
		end

		core.canvas = love.graphics.newCanvas(self.gameWidth, self.gameHeight)
		-- camera = gamera.new(0, 0, self.gameWidth, self.gameHeight)
		-- camera:setWindow(0, 0, w, h)
		-- self.cameraScale = h / self.gameHeight
		-- camera:setScale(self.cameraScale)
	end

return settings