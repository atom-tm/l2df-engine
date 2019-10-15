local core = l2df
local Scene = core.import 'core.class.entity.scene'
local UI = core.import 'core.class.entity.ui'
local parser = core.import 'parsers.lffs'

local Physix = core.import 'core.class.component.physix'
local event = core.import 'core.manager.event'

local Object = core.import 'core.class.entity.object'

local ball = Object {
	sprites = 'sprites/test/ball.png',
	x = 250,
	y = 250,
}
ball.vars.centerX = 25
ball.vars.centerY = 25

local room = Scene {
	nodes = {
		ball
	}
}

f = function (_, key)
	if key == 'w' then
		ball.vars.dvy = -4
	elseif key == 's' then
		ball.vars.dvy = 4
	elseif key == 'f2' then
		ball:getComponent(Physix).gravity = not ball:getComponent(Physix).gravity
	elseif key == 'f1' then
		ball:getComponent(Physix).platform = Physix:new({ bounce = 0.5 })
	end
end

event:subscribe('keypressed', f)

return room