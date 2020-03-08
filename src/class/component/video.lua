--- Video component
-- @classmod l2df.class.component.print
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local RenderManager = core.import 'manager.render'
local ResourceManager = core.import 'manager.resource'

local Video = Component:extend({ unique = false })

    --- Init
    -- @param table kwargs
    function Video:init()
        self.entity = nil
    end

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity entity
    function Video:added(entity, input, kwargs)
        if not entity then return false end
        self.entity = entity
        local vars = entity.vars
        input = input or { }
        kwargs = kwargs or { }
        vars[self] = {}

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0

        vars.scaleX = vars.scaleX or 1
        vars.scaleY = vars.scaleY or 1
        vars.hidden = vars.hidden or false

        local resource = input.resource or input[1]

        ResourceManager:loadAsync(resource, function (id, video)
            vars[self].resource = video
            if input.autoplay then
                vars[self].resource:play()
            end
        end)

        vars[self].color = kwargs.color and {
            (kwargs.color[1] or 255) / 255,
            (kwargs.color[2] or 255) / 255,
            (kwargs.color[3] or 255) / 255,
            (kwargs.color[4] or 255) / 255 }
        or { 1,1,1,1 }

    end

    function Video:play()
        if self.resource:isPlaying() then return false end
        self.resource:play()
        return true
    end

    --- Post-update event
    function Video:postUpdate()
        if not self.entity then return end
        local vars = self.entity.vars
        if not vars.hidden then
            RenderManager:add({
                object = vars[self].resource,

                z = vars.globalZ or vars.z,
                x = vars.globalX or vars.x,
                y = vars.globalY or vars.y,
                r = vars.r,

                color = vars[self].color,

            })
        end
    end

return Video