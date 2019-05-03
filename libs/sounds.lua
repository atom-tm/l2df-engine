local sounds = { }
	
	sounds.list = { }
	sounds.music = {
		file_path = nil,
		resource = nil
	}

	function sounds.setMusic(file_path)
		if sounds.music.file_path == file_path then
			sounds.music.resource:setVolume(settings.global.musicVolume * 0.01)
		else
			if sounds.music.resource then
				sounds.music.resource:stop()
			end
			sounds.music.file_path = file_path
			sounds.music.resource = love.audio.newSource(file_path, "static")
			sounds.music.resource:setLooping(true)
			sounds.music.resource:setVolume(settings.global.musicVolume * 0.01)
			sounds.music.resource:play()
		end
	end

	function sounds.load(file_path)
		for i in pairs(sounds.list) do
			if sounds.list[i].path == file_path then
				return sounds.list[i]
			end
		end
		local sound = {
			resource = love.audio.newSource(file_path,"static"),
			path = file_path
		}
		table.insert(sounds.list, sound)
		return sound
	end

	function sounds.play(sound)
		sound.resource:setVolume(settings.global.soundVolume * 0.01)
		sound.resource:play()
	end

	function sounds.setVolume(volume)
		settings.global.musicVolume = volume
		sounds.music.resource:setVolume(volume * 0.01)
	end

return sounds