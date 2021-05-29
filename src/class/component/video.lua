--- Video component. Inherited from @{l2df.class.component|l2df.class.Component} class.
-- @classmod l2df.class.component.video
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'

local RenderManager = core.import 'manager.render'
local ResourceManager = core.import 'manager.resource'

local Video = Component:extend({ unique = false })

    --- Resource used to play the video.
    -- To access use @{l2df.class.component.data|Video:data()} function.
    -- @field love.graphics.Video Video.data.resource

    --- True when video's playback is looped. False otherwise.
    -- To access use @{l2df.class.component.data|Video:data()} function.
    -- @field boolean Video.data.looped

    --- True if the video is hidding when it's paused or stopped. False otherwise.
    -- To access use @{l2df.class.component.data|Video:data()} function.
    -- @field boolean Video.data.hidding

    --- Blending color.
    -- To access use @{l2df.class.component.data|Video:data()} function.
    -- @field {0..1,0..1,0..1,0..1} Video.data.color

    --- Component was added to @{l2df.class.entity|Entity} event.
    -- Adds `"video"` key to the @{l2df.class.entity.C|Entity.C} table.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @param table kwargs  Keyword arguments.
    -- @param string kwargs.resource  Path to the video file. The only supported format is Ogg Theora.
    -- @param[opt=false] boolean kwargs.autoplay  Autoplay video as soon as the component becomes active.
    -- @param[opt=false] boolean kwargs.loop  True if component should loop the video. False otherwise.
    -- @param[opt=false] boolean kwargs.hiding  Hide the video when it's paused or stopped.
    -- @param[opt] {0..255,0..255,0..255,0..255} kwargs.color  RGBA color used for blending. Defaults to `{255, 255, 255, 255}` (white).
    function Video:added(obj, kwargs)
        if not obj then return false end
        local data = obj.data
        local odata = self:data(obj)
        kwargs = kwargs or { }

        obj.C.video = self:wrap(obj)

        odata.played = not not kwargs.autoplay
        odata.looped = not not kwargs.loop
        odata.hiding = not not kwargs.hiding

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
        } or { 1, 1, 1, 1 }
    end

    --- Component was removed from @{l2df.class.entity|Entity} event.
    -- Removes `"video"` key from @{l2df.class.entity.C|Entity.C} table.
    -- @param l2df.class.entity obj  Entity's instance.
    function Video:removed(obj)
        self.super.removed(self, obj)
        obj.C.video = nil
    end

    --- Method to control video playback.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @param string state  Action to do. One of: "play", "pause", "stop" or "toggle".
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
        elseif state == 'toggle' then
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

    --- Check video's playing state.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @return boolean  True if the video is playing. False otherwise.
    function Video:isPlaying(obj)
        local odata = self:data(obj)
        return odata.played and odata.resource:isPlaying()
    end

    --- Component post-update event handler.
    -- @param l2df.class.entity obj  Entity's instance.
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