--- Sound manager
-- @classmod l2df.manager.sound
-- @author Kasai
-- @copyright Atom-TM 2020

local core = l2df or require(((...):match('(.-)manager.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'SoundManager works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local type = _G.type
local lovePlay = love.audio.play
local loveStop = love.audio.stop

local music = nil
local sound_list = { }

local Manager = { sound_volume = 1, music_volume = 1 }

	--- Sounds volume.
	-- @field number Manager.sound_volume
	
	--- Music volume.
	-- @field number Manager.music_volume

	--- Configure @{l2df.manager.sound|SoundManager}.
	-- @param[opt] table kwargs  Keyword arguments.
	-- @param[opt=0.7] number kwargs.sound  Sounds volume. Value should be in range [0.0; 1.0].
	-- @param[opt=0.3] number kwargs.music  Music volume. Value should be in range [0.0; 1.0].
	-- @return l2df.manager.sound
	function Manager:init(kwargs)
		kwargs = kwargs or { }
		self.sound_volume = kwargs.sound or 0.7
		self.music_volume = kwargs.music or 0.3
		return self
	end

	--- Set background music.
	-- @param love.audio.Source source  Music `userdata` source for playing.
	-- @param[opt=false] boolean looping  True if the background music should be looped. False otherwise.
	-- @return boolean
	function Manager:setMusic(source, looping)
		if music == source or not (source and source.typeOf and source:typeOf('Source')) then
			return false
		end
		if music and music:typeOf('Source') then
			music:stop()
		end
		music = source
		music:setVolume(self.music_volume)
		music:setLooping(looping or false)
		music:play()
		return true
	end

	--- Check if source is a currently playing music.
	-- @param love.audio.Source source  Music `userdata` source.
	-- @return boolean
	function Manager:isPlaying(source)
		if music and music.typeOf and music:typeOf('Source') then
			if source and source.typeOf and source:typeOf('Source') then
				return music:isPlaying() and music == source
			end
			return music:isPlaying()
		end
		return false
	end

	--- Add sound to queue for playing.
	-- @param table|love.audio.Source input  Sound `userdata` source.
	-- @param[opt] love.audio.Source input.resource  Sound `userdata` source if input was passed as table.
	-- @param[opt=1] love.audio.Source input.volume  Sound volume. Value should be in range [0.0; 1.0].
	-- Defaults to @{Manager.sound_volume|SoundManager.sound_volume} or `1`.
	function Manager:play(input)
		local t = type(input)
		if t ~= 'table' and t ~= 'userdata' or
		not (input.typeOf and input:typeOf('Source')) and
		not (input.resource and input.resource.typeOf and input.resource:typeOf('Source'))
		then return end

		local sound = (input.resource or input):clone()
		input.volume = input.volume or self.sound_volume or 1
		sound:setVolume(input.volume)
		sound_list[#sound_list + 1] = sound
	end

	--- Stop all or list of playing sources / music.
	-- @param[opt] {love.audio.Source,...} sources
	function Manager:stop(sources)
		loveStop(sources)
	end

	--- Play all queued sounds.
	function Manager:update()
		lovePlay(sound_list)
		for i = #sound_list, 1, -1 do
			sound_list[i] = nil
		end
	end

return setmetatable(Manager, { __call = Manager.init })