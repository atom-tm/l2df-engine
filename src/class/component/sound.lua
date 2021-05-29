--- Sound component. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.sound
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'
local Sounds = core.import 'manager.sound'
local Resources = core.import 'manager.resource'

local type = _G.type
local assert = _G.assert

local Sound = Component:extend({ unique = false })

    --- Table describing &lt;sound&gt; structure.
    -- @field string|number id  Sound's ID. Would be used by @{l2df.class.component.sound.play|Sound:play()} function
    -- @field string file  Path to the audio file. Supported formats: MP3, Ogg Vorbis, WAVE
    -- @table .Sound

    --- Background music resource.
    -- To access use @{l2df.class.component.data|Sound:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field love.audio.Source Sound.data.music

    --- Background music looping.
    -- To access use @{l2df.class.component.data|Sound:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field boolean Sound.data.looping

    --- Array of sound IDs to be played at the end of the current frame.
    -- To access use @{l2df.class.component.data|Sound:data()} function or @{l2df.class.entity.data|Entity.data} directly.
    -- @field {number|string,...} Sound.data.sounds

    --- Component was added to @{l2df.class.entity|Entity} event.
    -- Adds `"sound"` key to the @{l2df.class.entity.C|Entity.C} table.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @param[opt] table kwargs  Keyword arguments.
    -- @param[opt] string|love.audio.Source kwargs.music  Path to the audio file or `userdata` with audio source.
    -- Links a passed audio resource with this component to play background music when entity is visible and active.
    -- @param[opt=false] boolean kwargs.looping  True if component should loop the background music. False otherwise.
    -- @param[opt=false] boolean kwargs.hidden  Applies to entity's hidden state.
    -- @param[opt] {l2df.class.component.sound.Sound,...} kwargs.sounds  Sounds' array to be preloaded with @{l2df.class.component.sound.add|Sound:add()} function.
    function Sound:added(obj, kwargs)
        if not obj then return false end
        local data = obj.data
        local odata = self:data(obj)
        kwargs = kwargs or { }

        obj.C.sound = self:wrap(obj)

        data.music = kwargs.music
        data.looping = not not kwargs.looping
        data.sounds = { }
        data.hidden = not not data.hidden

        odata.sound_map = { }
        local sounds = kwargs.sounds or { }
        for i = 1, #sounds do
            local sound = sounds[i]
            local id, file = sound[1] or sound.id or i, sound[2] or sound.file
            if id and type(file) == 'string' then
                odata.sound_map[id] = Resources:loadAsync(file)
            end
        end
    end

    --- Component was removed from @{l2df.class.entity|Entity} event.
    -- Removes `"sound"` key from @{l2df.class.entity.C|Entity.C} table.
    -- @param l2df.class.entity obj  Entity's instance.
    function Sound:removed(obj)
        self.super.removed(self, obj)
        obj.C.sound = nil
    end

    --- Load and add new sound to the list.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @param string file  Path to the sound file. Supported formats: MP3, Ogg Vorbis, WAVE.
    -- @param[opt] string|number sound_id  Sound's ID to be set explicitly. Assigns automatically if not passed.
    -- @return string|number  ID of the sound. Usefull when u did not pass it explicitly.
    function Sound:add(obj, file, sound_id)
        assert(type(file) == 'string', 'Parameter "file" for SoundComponent:add is required and must be a string')
        local odata = self:data(obj)
        sound_id = sound_id or (#odata.sound_map + 1)
        odata.sound_map[sound_id] = Resources:loadAsync(file)
        return sound_id
    end

    --- Play the previously loaded with @{l2df.class.component.sound.add|Sound:add()} function sound.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @param string|number sound_id  ID of the sound to be played.
    function Sound:play(obj, sound_id)
        obj.data.sounds[#obj.data.sounds + 1] = sound_id
    end

    --- Component post-update event handler.
    -- @param l2df.class.entity obj  Entity's instance.
    function Sound:postupdate(obj)
        local data = obj.data
        local odata = self:data(obj)
        if data.hidden then return end
        if type(data.music) then
            Sounds:setMusic(data.music, not not data.looping)
            odata.music = data.music
            data.music = nil
        end
        for i = 1, #data.sounds do
            Sounds:add(Resources:get( odata.sound_map[data.sounds[i]] ))
            data.sounds[i] = nil
        end
    end

return Sound