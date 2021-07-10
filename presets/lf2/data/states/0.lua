return function (obj, data)
	local control = obj.C.controller
	local frames = obj.C.frames
	if not (control and frames) then return end

	if control.hitted('jump') then
		frames.set(210) -- jump
	-- elseif control.hitted('attack') then
	-- 	frames.set('attack')
	elseif control.pressed('up') == control.pressed('down') and control.pressed('left') == control.pressed('right') then
		data.vx, data.vz = 0, 0
	elseif control.doubled('left') or control.doubled('right') then
		frames.set('running')
	else
		frames.set('walking')
	end
end