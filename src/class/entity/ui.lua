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
local Script = core.import 'class.component.script'

local UI = Entity:extend()

    function UI:init(kwargs)
        self:addComponent(Transform())
        local vars = self.vars
        vars.x = kwargs.x or vars.x
        vars.y = kwargs.y or vars.y
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
        self.vars.pic = kwargs.pic or self.vars.pic or 1
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

    UI.Button = UI:extend({ name = 'button' })
    function UI.Button:init(kwargs)

        self:super(kwargs)

        self.blocked = false
        self.cooldown_time = kwargs.cooldown or 0
        self.cooldown = 0

        local states = kwargs.states or kwargs[1]
        states = type(states) == "table" and states or { }

        self.states = {}
        self.states[1] = states.normal or states[1]
        assert(self.states[1] and self.states[1].isInstanceOf and self.states[1]:isInstanceOf(UI), "Requires a UI type object")

        self.states[2] = (states.focus and states.focus.isInstanceOf and states.focus:isInstanceOf(UI) and states.focus) or self.states[1]
        self.states[3] = (states.hover and states.hover.isInstanceOf and states.hover:isInstanceOf(UI) and states.hover) or self.states[2]
        self.states[4] = (states.click and states.click.isInstanceOf and states.click:isInstanceOf(UI) and states.click) or self.states[3]

        self.state = 1
        self.last_state = self.state

        self:attach(self.states[self.state])

        self.action = kwargs.action or kwargs[2]
        self.action = type(self.action) == "function" and self.action or function() end

        self:addComponent(Script(), function ()
            if self.state ~= self.last_state then
                self.last_state = self.state
                self:detachAll()
                self:attach(self.states[self.state])
            end
            self.state = self.cooldown == 0 and 1 or self.state
            self.cooldown = self.cooldown > 0 and self.cooldown - 1 or self.cooldown
        end)
    end

    function UI.Button:focus()
        self.state = self.state < 2 and 2 or self.state
    end

    function UI.Button:hover()
        self.state = self.state < 3 and 3 or self.state
    end

    function UI.Button:click()
        if self.state == 4 then return end
        self.state = 4
        self:action()
        self.cooldown = self.cooldown_time
    end


    UI.Menu = UI:extend({ name = 'menu' })
    function UI.Menu:init(kwargs, list)
        self:super(kwargs)
        local list = kwargs.list

        assert(type(list) == "table" and #list > 0, "You fucker, there should be a list of buttons here!")

        for i = 1, #list do
            assert(list[i].isInstanceOf and list[i].isInstanceOf(UI.Button), "Who the fuck are you trying to fuck? There should be a button!")
            self:attach(list[i])
        end

        self.list = self:getNodes()

        self.selected = 1

        self:addComponent(Script(), function ()
            local list = self:getNodes()
            list[self.selected]:focus()
        end)
    end

    function UI.Menu:next()
        local list = self:getNodes()
        self.selected = self.selected == #list and 1 or self.selected + 1
    end

    function UI.Menu:prev()
        local list = self:getNodes()
        self.selected = self.selected == 1 and #list or self.selected - 1
    end

    function UI.Menu:choice()
        local list = self:getNodes()
        list[self.selected]:click()
    end





return setmetatable({ UI.Text, UI.Image, UI.Animation, UI.Video, UI.Button, UI.Menu }, { __index = UI })