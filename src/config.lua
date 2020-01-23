--- Configs and settings
-- @module l2df.config
-- @author Kasai, Abelidze
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)[^%.]+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Config works only with l2df v1.0 and higher')

local DatParser = core.import 'class.parser.dat'

local strgmatch = string.gmatch
local type = _G.type

local config = {
	global = {
		data_path = 'data/data.txt',		-- Путь до data.txt (список объектов и карт движка)
		frames_path = 'data/frames.dat',	-- Путь до frames.dat (список кадров по умолчанию)
		combos_path = 'data/combos.dat',	-- Путь до combos.dat (список переходов по комбинациям клавиш)
		dtypes_path = 'data/dtypes.dat',	-- Путь до dtypes.dat (список поведения при разных типах урона)
		system_path = 'data/system.dat',	-- Путь до system.dat
		rooms_path = '/rooms/',				-- Папка с файлами комнат
		states_path = '/data/states/',		-- Папка с файлами стейтов
		kinds_path = '/data/kinds/',		-- Папка с файлами типов взаимодействий
		langs_path = '/data/langs',			-- Папка с файлами локализаций
		ui_path = '/sprites/UI/',			-- Папка с элементами оформления

		lang = 'en',						-- Язык локализации
		resolution = 3,						-- Текущее разрешение холста
		difficulty = 2, 					-- Сложность игры (от 1 до 3)
		width = 854, 						-- Ширина окна игры
		height = 480, 						-- Высота окна игры
		music_volume = 50,					-- Громкость музыки
		sound_volume = 100,					-- Громкость звука
		debug = true,						-- Показ отладочной информации
	},

	resolutions = {							-- Доступные разрешения холста игры
		{ width = 854, height = 480 },			-- 854х480
		{ width = 1024, height = 576 },			-- 1024х576
		{ width = 1280, height = 720 },			-- 1280х720
		{ width = 1366, height = 768 },			-- 1366х768
		{ width = 1600, height = 900 },			-- 1600х900
		{ width = 1920, height = 1080 },		-- 1920х1080
	},

	file = 'data/settings.dat',				-- Путь файла настроек игры
	gameWidth = 0, 							-- Ширина холста игры
	gameHeight = 0, 						-- Высота холста игры

	graphic = {								-- Настройки графической составляющей игры
		fpsLimit = 60,							-- Ограничение FPS
		fullscreen = false,						-- Полный экран
		vsync = false,							-- Вертикальная синхронизация
		shadows = true,							-- Детализированные тени
		reflections = true,						-- Отражения
		smoothing = true,						-- Фильтрация текстур
		effects = true,							-- Количество эффектов и частиц
		details = true,							-- Показ необязательных элементов
	},

	keys = { 'up', 'down', 'left', 'right', 'attack', 'jump', 'defend', 'special1' },
}

local Module = { }

	function Module:get(str)
		str = type(str) == 'string' and str or ''
		local result
		for k in strgmatch(str, '[^%.]+') do
			result = result and result[k] or config[k]
		end
		return result or config
	end

	function Module:set(str, val)
		str = type(str) == 'string' and str or ''
		local lastKey, result = nil, config
		for k in strgmatch(str, '[^%.]+') do
			if lastKey then
				result[lastKey] = type(result[lastKey]) == 'table' and result[lastKey] or {}
				result = result[lastKey]
			end
			lastKey = k
		end
		result[lastKey] = val
	end

	function Module:load(filepath)
		config.file = filepath or config.file
		config = DatParser:parseFile(config.file, config)
	end

	function Module:save()
		DatParser:dumpToFile(config.file, config)
		-- if input.controls ~= config.controls then
		-- 	input:updateMappings(config.controls)
		-- end
	end

	function Module:apply()
		print('Saved')
		--[[
			math.randomseed(love.timer.getTime())
			love.graphics.setDefaultFilter('nearest', 'nearest')

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
		]]
	end

return setmetatable(Module, {
	__index = config,
	__call = function (self, k, v) return v and self:set(k, v) or self:get(k) end
})