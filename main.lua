love.graphics.setDefaultFilter("nearest", "nearest")
math.randomseed(love.timer.getTime())
require "libs.globals"

--require "libs.entites"
--require "libs.drawing"
--require "libs.physics"
--require "libs.collisions"

--require "libs.controls"
--require "libs.battle"
--require "libs.loading"
--require "libs.states"


function love.load()
	-- FPS Локер --
	min_dt = 1/60 -- требуемое фпс
    next_time = love.timer.getTime()
    ---------------
    settings:Read("data/settings.txt")
    func.SetWindowSize()
    loc:Set(loc.id)
    data:Load("data/data.txt")
    rooms:Set("main_menu")
end

function love.update(dt)
	rooms.current:Update()
	next_time = next_time + min_dt
end 



function love.draw()

	camera:draw(function(l,t,w,h)
		rooms.current:Draw()
	end)

	local cur_time = love.timer.getTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep(next_time - cur_time)
end 




function love.keypressed( button, scancode, isrepeat )
	rooms.current:Keypressed(button)
end
function love.joystickpressed( joystick, button )
	rooms.current:Keypressed("Joy"..button)
end
function love.joystickhat( joystick, hat, direction )
	if direction ~= "c" then
		rooms.current:Keypressed("Joy"..hat..button)
	end
end