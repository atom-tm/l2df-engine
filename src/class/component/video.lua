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
    function Video:added(entity, kwargs)
        if not entity then return false end
        self.entity = entity
        local vars = self.entity.vars
        kwargs = kwargs or { }
        vars[self] = {}

        vars[self].delayed_start = kwargs.autoplay
        vars[self].looped = kwargs.loop
        vars[self].hide_when_paused = kwargs.hiding

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0

        vars.scaleX = vars.scaleX or 1
        vars.scaleY = vars.scaleY or 1
        vars.hidden = vars.hidden or false

        local resource = kwargs.resource.resource or kwargs.resource[1]

        ResourceManager:loadAsync(resource, function (id, video)
            vars[self].resource = video
            if vars[self].delayed_start then
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

    function Video:setState(state)
        local vars = self.entity.vars
        if state == "play" then
            if vars[self].resource then vars[self].resource:play() end
            vars[self].delayed_start = true
        elseif state == "stop" then
            if vars[self].resource then
                vars[self].resource:pause()
                vars[self].resource:rewind()
            end
            vars[self].delayed_start = false
        elseif state == "pause" then
            if vars[self].resource then vars[self].resource:pause() end
            vars[self].delayed_start = false
        elseif state == "invert" then
            if vars[self].resource then
                if vars[self].resource:isPlaying() then
                    vars[self].resource:pause()
                else
                    vars[self].resource:play()
                end
            end
            vars[self].delayed_start = not vars[self].delayed_start
        else
            return false
        end
        return true
    end


    --- Post-update event
    function Video:postUpdate()
        if not self.entity then return end
        local vars = self.entity.vars

        if vars[self].resource then
            if vars[self].looped and vars[self].delayed_start and not vars[self].resource:isPlaying() then
                vars[self].resource:rewind()
                vars[self].resource:play()
            end
            if vars[self].hide_when_paused and not vars[self].resource:isPlaying() then return end
        else return end


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