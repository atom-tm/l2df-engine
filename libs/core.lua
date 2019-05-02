gamera		= require "libs.external.gamera"
json 		= require "libs.external.json"
---------------------------------------------
settings 	= require "libs.settings"
object 		= require "libs.object"
helper 		= require "libs.helper"


rooms 		= require "libs.rooms"
ui 			= require "libs.ui"
loc 		= require "libs.localization"
data 		= require "libs.data"

sounds 		= require "libs.sounds"
image 		= require "libs.images"
videos 		= require "libs.videos"
resources	= require "libs.resources"
font 		= require "libs.fonts"

--battle		= require "libs.battle"
---------------------------------------------
camera = nil
locale = nil
---------------------------------------------
local canvas_xsize, canvas_ysize = 1,1
local core = {}

	function core.init()
		settings:init()

		-- FPS Limiter initialize --
		min_dt = 1 / settings.global.graphic.fpsLimit
		next_time = love.timer.getTime()
		----------------------------

		helper.interception("update",core.update)
		helper.interception("draw",core.draw)
		helper.interception("resize",core.resize)


		rooms:init()
	end

	function core.update()
		-- Mouse position calculation --
		local x, y = love.mouse.getPosition( )
		settings.mouseX = x * (settings.gameWidth / settings.global.windowWidth)
		settings.mouseY = y * (settings.gameHeight / settings.global.windowHeight)
		--------------------------------
		next_time = next_time + min_dt -- FPS Limiter
	end

	function core.draw()
		if mainCanvas then
			love.graphics.draw(mainCanvas, 0, 0, 0, settings.canvasW, settings.canvasH)
		end
		font.print(settings.mouseClick, 100, 100)
		-- FPS Limiter working --
		local cur_time = love.timer.getTime()
		if next_time <= cur_time then
			next_time = cur_time
			return
		end
		love.timer.sleep(next_time - cur_time)
		-------------------------
	end

	function core.resize(w, h)
		if mainCanvas then
			settings.canvasW = w / settings.gameWidth
			settings.canvasH = h / settings.gameHeight
			settings.global.windowWidth = w
			settings.global.windowHeight = h
		end
	end

return core