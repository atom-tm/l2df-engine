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

    --- Init
    -- @param table kwargs
    function Sound:init()
        self.entity = nil
    end

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity entity
    function Sound:added(entity, kwargs)
        if not entity then return false end
        self.entity = entity
        local vars = self.entity.vars
        kwargs = kwargs or { }
        vars[self] = {}

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0

        vars.sound = vars.sound or nil
        vars.hidden = vars.hidden or false

        for i = 1, kwargs do
            if type(kwargs[i]) == "string" then
                ResourceManager:loadAsync(kwargs[i])
            end
        end
    end

    function Sound:add(file)
        ResourceManager:load(file)
    end

    function Sound:play(file)
        self.entity.vars.sound = file
    end

    --- Post-update event
    function Video:postUpdate()
        if not self.entity then return end
        local vars = self.entity.vars

        if not vars.hidden and type(vars.sound) == "string" then
            SoundManager:add({
                resource = ResourceManager:get(vars.sound)
            })
        end
    end

return Video