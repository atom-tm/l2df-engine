local Input = l2df.import 'manager.input'
local Timer = l2df.import 'class.timer'

return function (cursor, btn, itr)
	if btn.key == 'MENU' and not btn.timer and Input:consume('click') then
		btn.parent.R.CONTROL.active = true
		btn.timer = Timer(300, function (timer)
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