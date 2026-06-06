local core = assert(l2df, 'L2DF is not available')
local Input = core.import 'manager.input'
local Timer = core.import 'class.timer'

return function (cursor, btn, itr)
	if btn.key == 'MENU' and not btn.timer and Input:consume('click') then
		btn.parent.R.CONTROL.active = true
		btn.timer = Timer(5 * core.fps, function (timer)
			btn.parent.R.CONTROL.active = false
			btn.timer = timer:dispose()
		end)
	else
		_ = btn.parent.hover and btn.parent:hover()
		if btn.parent.click and Input:consume('click') then
			btn.parent:click()
		end
	end
end