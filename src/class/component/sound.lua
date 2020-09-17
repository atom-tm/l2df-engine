--- Sound component
-- @classmod l2df.class.component.print
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

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity obj
    -- @param table kwargs
    -- @param table kwargs
    function Sound:added(obj, kwargs)
        if not obj then return false end
        local data = obj.data
        local odata = self:data(obj)
        kwargs = kwargs or { }

        data.music = kwargs.music
        data.looping = kwargs.looping
        data.sounds = { }
        data.hidden = data.hidden or false

        odata.sound_map = { }
        local sounds = kwargs.sounds or { }
        for i = 1, #sounds do
            local sound = sounds[i]
            local id, file = sound[1] or sound.id, sound[2] or sound.file
            if id and type(file) == 'string' then
                odata.sound_map[id] = Resources:loadAsync(file)
            end
        end
    end

    ---
    -- @param l2df.class.entity obj
    -- @param string file
    -- @param[opt] string|number sound_id
    -- @return string|number  Sound id
    function Sound:add(obj, file, sound_id)
        assert(type(file) == 'string', 'Parameter "file" for SoundComponent:add is required and must be a string')
        local odata = self:data(obj)
        sound_id = sound_id or (#odata.sound_map + 1)
        odata.sound_map[sound_id] = Resources:loadAsync(file)
        return sound_id
    end

    ---
    -- @param l2df.class.entity obj
    -- @param string|number sound_id
    function Sound:play(obj, sound_id)
        obj.data.sounds[#obj.data.sounds + 1] = sound_id
    end

    --- Post-update event
    -- @param l2df.class.entity obj
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