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
settings:initialize()
settings:load()
rooms:initialize()

local _tempLoad = love.load
function love.load()
	_tempLoad()
	-- FPS Limiter initislize --
	min_dt = 1/settings.fpsLimit
	next_time = love.timer.getTime()
	----------------------------
end

local _tempUpdate = love.update
function love.update()
	_tempUpdate()



	next_time = next_time + min_dt -- FPS Limiter
end


local _tempDraw = love.draw
function love.draw()
	_tempDraw()


	-- FPS Limiter working --
	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
	-------------------------
end