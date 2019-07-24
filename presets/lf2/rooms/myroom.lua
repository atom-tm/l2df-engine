local l2df = l2df
local ui = l2df.ui
local data = l2df.data
local settings = l2df.settings.global
local sound = l2df.sound

local room = {}

	local TEMP = ui.Button(ui.Text("ОКНО", nil,nil,nil,{1,1,1,1}), 10, 10, nil, nil, nil, nil, nil, true)
	TEMP.click = function ()
		if settings.music_volume == 0 then
			sound:setVolume(100)
		else
			sound:setVolume(0)
		end
	end

	room.nodes = {
		TEMP
	}


return room