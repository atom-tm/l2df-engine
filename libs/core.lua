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
resourses	= require "libs.resourses"
font 		= require "libs.fonts"

battle		= require "libs.battle"
---------------------------------------------
camera = nil
locale = nil
---------------------------------------------
--settings:load()

local core = {}

	function core.initialize()
		-- FPS Limiter initislize --
		min_dt = 1/settings.fpsLimit
		next_time = love.timer.getTime()
		----------------------------
		local _tempUpdate = love.update
		love.update = function (dt)
			_tempUpdate(dt)
			core.update(dt)
		end
		local _tempDraw = love.draw
		love.draw = function ( )
			_tempDraw()
			core.draw()
		end
		settings:initialize()
		rooms:initialize()
	end

	function core.update()
		rooms.current:update()
		next_time = next_time + min_dt -- FPS Limiter
	end

	function core.draw()
		rooms.current:draw()
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