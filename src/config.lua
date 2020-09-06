--- Configs and settings
-- @module l2df.config
-- @author Abelidze
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)[^%.]+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Config works only with l2df v1.0 and higher')

local DatParser = core.import 'class.parser.dat'
local LffsParser = core.import 'class.parser.lffs2'

local type = _G.type
local strgmatch = string.gmatch

local config = {
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

	resolutions = {							-- Доступные разрешения холста игры
		{ width = 854, height = 480 },			-- 854х480
		{ width = 1024, height = 576 },			-- 1024х576
		{ width = 1280, height = 720 },			-- 1280х720
		{ width = 1366, height = 768 },			-- 1366х768
		{ width = 1600, height = 900 },			-- 1600х900
		{ width = 1920, height = 1080 },		-- 1920х1080
	},

	file = 'data/settings.dat',				-- Путь файла настроек игры
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
		if lastKey then result[lastKey] = val end
	end

	function Module:load(filepath)
		config.file = filepath or config.file
		config = LffsParser:parseFile(config.file, config)
	end

	function Module:save()
		DatParser:dumpToFile(config.file .. '.dat', config)
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