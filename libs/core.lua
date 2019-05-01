gamera		= require "libs.external.gamera"
json 		= require "libs.external.json"
---------------------------------------------
settings 	= require "libs.settings"
rooms 		= require "libs.rooms"
loc 		= require "libs.localization"
data 		= require "libs.data"
helper 		= require "libs.helper"

sounds 		= require "libs.sounds"
image 		= require "libs.images"
resources	= require "libs.resources"
font 		= require "libs.fonts"

battle		= require "libs.battle"
---------------------------------------------
camera = nil
locale = nil
---------------------------------------------
--settings:load()

local core = {}

	function core.init()
		-- FPS Limiter initialize --
		min_dt = 1 / settings.fpsLimit
		next_time = love.timer.getTime()
		----------------------------

		local update = love.update
		love.update = function (dt)
			update(dt)
			core.update(dt)
		end

		local draw = love.draw
		love.draw = function ()
			draw()
			core.draw()
		end

		settings:init()
		helper.SetWindowSize()
		loc:Set(1)
		data:Load("data/data.txt")
		data:Frames("data/frames.dat")
		data:DTypes("data/damage_types.dat")
		data:System("data/system.dat")
		data:States("states")
		data:Kinds("kinds")
		rooms:init()
	end

	function core.update()
		next_time = next_time + min_dt -- FPS Limiter
	end

	function core.draw()
		-- FPS Limiter working --
		local cur_time = love.timer.getTime()
		if next_time <= cur_time then
			next_time = cur_time
			return
		end
		love.timer.sleep(next_time - cur_time)
		-------------------------
	end

return core