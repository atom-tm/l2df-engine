--- UI entities module
-- @classmod l2df.class.entity.ui
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Entities works only with l2df v1.0 and higher')

local Entity = core.import 'class.entity'
local Render = core.import 'class.component.render'
local Frames = core.import 'class.component.frames'
local States = core.import 'class.component.states'
local Print = core.import 'class.component.print'
local Video = core.import 'class.component.video'
local Transform = core.import 'class.component.transform'
local Physix = core.import 'class.component.physix'

local UI = Entity:extend()

    function UI:init(kwargs)
        self:addComponent(Transform())
        local vars = self.vars
        vars.x = kwargs.x
        vars.y = kwargs.y
        vars.hidden = kwargs.hidden
    end

    function UI:on(event, callback)
        assert(type(event) == "string", "Event name must be string")
        assert(type(callback) == "function", "Callback must be a function")
        if type(self[event]) == "function" then
            local old = self[event]
            self[event] = function (...)
                old(...)
                callback(...)
            end
        end
        return self
    end

    function UI:hide()
        self.vars.hidden = true
        return self
    end

    function UI:show()
        self.vars.hidden = false
        return self
    end

    function UI:toggle()
        self.vars.hidden = not self.vars.hidden
        return self
    end


    UI.Text = UI:extend({ name = 'text' })
    function UI.Text:init(kwargs)
        self:super(kwargs)
        self:addComponent(Print(), kwargs)
    end

    UI.Image = UI:extend({ name = 'image' })
    function UI.Image:init(kwargs)
        self:super(kwargs)
        self:addComponent(Render(), kwargs.sprites)
    end

    UI.Animation = UI:extend({ name = 'animation' })
    function UI.Animation:init(kwargs)
        self:super(kwargs)
        self:addComponent(Render(), kwargs.sprites)
        self:addComponent(Frames(), 1, kwargs.nodes)
    end

    UI.Video = UI:extend({ name = 'video' })
    function UI.Video:init(kwargs)
        self:super(kwargs)
        self:addComponent(Video(), kwargs)
    end

    function UI.Video:play()
        self:getComponent(Video):setState("play")
    end

    function UI.Video:pause()
        self:getComponent(Video):setState("pause")
    end

    function UI.Video:stop()
        self:getComponent(Video):setState("stop")
    end

    function UI.Video:invert()
        self:getComponent(Video):setState("invert")
    end



    --[[UI.Image = UI:extend({ name = 'image' })
    function UI.Image:init(kwargs)
        self:super(kwargs)
        self:addComponent(Render(), kwargs.sprites)
    end


    UI.Animation = UI:extend({ name = 'animation' })
    function UI.Animation:init(kwargs)
        self:super(kwargs)
        self:addComponent(Render(), kwargs.sprites)
        self:addComponent(Frames(), 1, kwargs.nodes)
    end]]

return setmetatable({ UI.Text, UI.Image, UI.Animation, UI.Video }, { __index = UI })