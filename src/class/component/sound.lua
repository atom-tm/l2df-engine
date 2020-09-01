--- Sound component
-- @classmod l2df.class.component.print
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local SoundManager = core.import 'manager.sound'
local ResourceManager = core.import 'manager.resource'

local Sound = Component:extend({ unique = false })

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity obj
    function Sound:added(obj, kwargs)
        if not obj then return false end
        local data = obj.data
        local odata = self:data(obj)
        kwargs = type(kwargs) == "table" and kwargs or { }

        data.sound = data.sound or nil
        data.hidden = data.hidden or false

        odata.sound_map = { }
        for id, key in pairs(kwargs) do
            if (type(id) == "string" or type(id) == "key") and type(key) == "string" then
                odata.sound_map[id] = ResourceManager:loadAsync(key)
            end
        end
    end

    function Sound:add(obj, file, id)
        local odata = self:data(obj)
        id = id or (#odata.sound_map + 1)
        odata.sound_map[id] = ResourceManager:load(file)
    end

    function Sound:play(obj, id)
        obj.data.sound = id
    end

    --- Post-update event
    function Sound:postupdate(obj)
        local data = obj.data
        local odata = self:data(obj)

        if not data.hidden and type(data.sound) == "string" then
            SoundManager:add({
                resource = ResourceManager:get(odata.sound_map[data.sound])
            })
        end
        data.sound = nil
    end

return Sound