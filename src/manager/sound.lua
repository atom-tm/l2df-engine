--- Sound manager
-- @classmod l2df.manager.render
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'SoundManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local play = love.audio.play

local sound_list = {  }
local music = nil

local Manager = {  }

	function Manager:init()
		self.sound_volume = 0.7
		self.music_volume = 0.3
	end

	-- Установка музыки
	function Manager:setMusic(source, looping)
		local isOldMusic = music and music:typeOf("Source")
		if not source or not source.typeOf or not source:typeOf("Source") then
			if isOldMusic then music:stop() end
			return
		end
		if music == source then return end
		if isOldMusic then music:stop() end
		music = source
		music:setVolume(self.music_volume)
		music:setLooping(looping or false)
		music:play()
	end

	-- Проверка музыки
	function Manager:isMusic(source)
		if music and music.typeOf and music:typeOf("Source") then
			if source and source.typeOf and source:typeOf("Source") then
				return music:isPlaying() and music == source
			else
				return music:isPlaying()
			end
		end
		return false
	end


	function Manager:add(input)
		if not input
		or not input.resource
		or not input.resource.typeOf
		or not input.resource:typeOf("Source")
		then return end

		local sound = input.resource:clone()

		input.volume = input.volume or self.sound_volume or 1
		sound:setVolume(input.volume)

		sound_list[#sound_list + 1] = sound
	end


	function Manager:play()
		play(sound_list)
		sound_list = { }
	end

return Manager