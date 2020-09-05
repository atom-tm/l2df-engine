--- Video component
-- @classmod l2df.class.component.video
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local RenderManager = core.import 'manager.render'
local ResourceManager = core.import 'manager.resource'

local Video = Component:extend({ unique = false })

    --- Component added to l2df.class.entity
    -- @param l2df.class.entity obj
    function Video:added(obj, kwargs)
        if not obj then return false end
        local data = obj.data
        local odata = self:data(obj)
        kwargs = kwargs or { }

        odata.played = kwargs.autoplay
        odata.looped = kwargs.loop
        odata.hiding = kwargs.hiding

        data.x = data.x or 0
        data.y = data.y or 0
        data.z = data.z or 0
        data.r = data.r or 0

        data.scalex = data.scalex or 1
        data.scaley = data.scaley or 1
        data.hidden = data.hidden or false

        ResourceManager:loadAsync(kwargs.resource, function (id, video)
            odata.resource = video
            if odata.played then
                odata.resource:play()
            end
        end)

        odata.color = kwargs.color and {
            (kwargs.color[1] or 255) / 255,
            (kwargs.color[2] or 255) / 255,
            (kwargs.color[3] or 255) / 255,
            (kwargs.color[4] or 255) / 255
        } or { 1,1,1,1 }
    end

    ---
    -- @param l2df.class.entity obj
    -- @param string state
    function Video:setState(obj, state)
        local data = obj.data
        local odata = self:data(obj)
        if state == 'play' then
            if odata.resource then odata.resource:play() end
            odata.played = true
        elseif state == 'stop' then
            if odata.resource then
                odata.resource:pause()
                odata.resource:rewind()
            end
            odata.played = false
        elseif state == 'pause' then
            if odata.resource then odata.resource:pause() end
            odata.played = false
        elseif state == 'invert' then
            if odata.resource then
                if odata.resource:isPlaying() then
                    odata.resource:pause()
                else
                    odata.resource:play()
                end
            end
            odata.played = not odata.played
        else
            return false
        end
        return true
    end

    --- Post-update event
    function Video:postupdate(obj)
        local data = obj.data
        local odata = self:data(obj)

        if not odata.resource then
            return
        elseif odata.looped and odata.played and not odata.resource:isPlaying() then
            odata.resource:rewind()
            odata.resource:play()
            return
        elseif odata.hiding and not odata.resource:isPlaying() then
            return
        end

        if not data.hidden then
            RenderManager:draw({
                -- layer = data.layer,
                object = odata.resource,
                z = data.globalZ or data.z,
                x = data.globalX or data.x,
                y = data.globalY or data.y,
                r = data.r,
                sx = data.scalex,
                sy = data.scaley,
                color = odata.color,
            })
        end
    end

return Video