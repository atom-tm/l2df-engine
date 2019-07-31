local l2df = l2df
local ui = l2df.ui
local data = l2df.data
local settings = l2df.settings.global

local room = { }

	local loading_ended = false

	local loading_anim = ui.Animation("sprites/UI/loading.png", 8, 8, 140, 140, 4, 3, 12, 2, true)
	local loaded_text = ui.Text("press_anykey", nil, 8, 8, { 1, 1, 1, 1})

	room.nodes = {
		loading_anim,
		loaded_text,
	}

	function room:load()
		loaded_text:hide()
	end

	function room:update()
		if loading_ended then return end
	end

	function room:keypressed()
		if loading_ended then
			l2df.rooms:set("menu")
		end
	end

	function room:mousepressed()
		if loading_ended then
			l2df.rooms:set("menu")
		end
	end


	function room:exit()
		for i = 1, #self.nodes do
			if self.nodes[i].stop then self.nodes[i]:stop() end
		end
	end

return room