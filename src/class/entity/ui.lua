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
local Transform = core.import 'class.component.transform'
local Physix = core.import 'class.component.physix'

local UI = Entity:extend()

    function UI:init(kwargs)
        local vars = self.vars
        vars.x = kwargs.x or 0
        vars.y = kwargs.y or 0
        vars.z = kwargs.z or 0
        vars.hidden = kwargs.hidden or false
        self:addComponent(Transform())
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

        UI.Image = UI:extend({ name = 'image' })
        function UI.Image:init(kwargs)
            self:super(kwargs)
            self:addComponent(Render(), kwargs.sprites)
        end

        UI.Text = UI:extend({ name = 'text' })
        function UI.Text:init(kwargs)
            self:super(kwargs)
            self:addComponent(Print(kwargs))
        end

        UI.Animation = UI:extend({ name = 'animation' })
        function UI.Animation:init(kwargs)
            self:super(kwargs)
            self:addComponent(Render(), kwargs.sprites)
            self:addComponent(Frames(), 1, kwargs.nodes)
        end

return setmetatable({ UI.Image, UI.Animation, UI.Text }, { __index = UI })