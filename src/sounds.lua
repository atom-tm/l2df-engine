local sounds = { }
	
	sounds.list = { }
	sounds.music = {
		filepath = nil,
		resource = nil,
	}
	sounds.config = {
		music_volume = 100,
		sound_volume = 100,
	}

	function sounds:setConfig(config)
		assert(type(config) == "table", "Sounds' config must be a table")
		assert(config.music_volume, "Sounds' config must contain 'music_volume' property")
		assert(config.sound_volume, "Sounds' config must contain 'sound_volume' property")

		self.config = config
	end

	function sounds:load(filepath)
		for i in pairs(self.list) do
			if self.list[i].path == filepath then
				return self.list[i]
			end
		end
		local sound = {
			resource = love.audio.newSource(filepath, "static"),
			path = filepath
		}
		self.list[#self.list + 1] = sound
		return sound
	end

	function sounds:setMusic(filepath)
		if self.music.filepath == filepath then
			self.music.resource:setVolume(self.config.music_volume * 0.01)
		else
			if self.music.resource then
				self.music.resource:stop()
			end
			self.music.filepath = filepath
			self.music.resource = love.audio.newSource(filepath, "static")
			self.music.resource:setLooping(true)
			self.music.resource:setVolume(self.config.music_volume * 0.01)
			self.music.resource:play()
		end
	end

	function sounds:play(sound)
		sound.resource:setVolume(self.config.sound_volume * 0.01)
		sound.resource:play()
	end

	function sounds:setVolume(volume)
		self.config.music_volume = volume
		self.music.resource:setVolume(volume * 0.01)
	end

return sounds