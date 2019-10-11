local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'core.class.component'
local EventManager = core.import 'core.manager.event'
local helper = core.import 'helper'

local Physix = Component:extend({ unique = true })

    local stack = { }

    Physix.Controller = Component:extend({ unique = true })
    function Physix.Controller:init(...)
        self:set(...)
    end

    function Physix.Controller:set(kwargs)
        kwargs = kwargs or { }
        self.gravity = kwargs.gravity or 0.0098
        self.maxSpeed = kwargs.maxSpeed or 10
        self.wind = kwargs.wind or 0
        self.friction = helper.bound(kwargs.friction, 0, 1) and kwargs.friction or 0.99
    end

    function Physix.Controller:push()
        stack[#stack + 1] = self
    end

    function Physix.Controller:pop()
        stack[#stack] = nil
    end

    stack = { Physix.Controller:new() }


    function Physix:init(...)
        self.entity = nil
        self.vars = nil
        self.velocityX = 0
        self.velocityY = 0
        self.velocityZ = 0
        self.platform = nil
        self:set(...)
    end

    function Physix:set(kwargs)
        kwargs = kwargs or { }
        self.gravity = kwargs.gravity or false
        self.through = kwargs.through or true
        self.static = kwargs.static or false
        self.weight = helper.bound(kwargs.weight, 0, 1000) or 1
        self.bounce = helper.bound(kwargs.bounce, 0, 1) or 0
        self.friction = helper.bound(kwargs.friction, 0, 1) or 0.50

        EventManager:subscribe('collide', self.collide, nil, self)
    end

    function Physix:added(entity, vars)
        if not entity then return false end
        self.entity = entity
        self.vars = vars

        vars.dx = vars.dx or 0
        vars.dy = vars.dy or 0
        vars.dz = vars.dz or 0
        vars.dvx = vars.dvx or 0
        vars.dvy = vars.dvy or 0
        vars.dvz = vars.dvz or 0
        vars.dsx = vars.dsx or 0
        vars.dsy = vars.dsy or 0
        vars.dsz = vars.dsz or 0
    end

    function Physix:update()
        local vars = self.vars
        local c = stack[#stack]

        self.velocityX = self.velocityX * (self.platform and self.platform.friction or 1) * c.friction
        self.velocityX = vars.dvx ~= 0 and vars.dvx or self.velocityX + vars.dsx + c.wind
        self.velocityX = self.velocityX < c.maxSpeed and self.velocityX or c.maxSpeed
        self.velocityX = self.velocityX > -c.maxSpeed and self.velocityX or -c.maxSpeed
        vars.dsx, vars.dvx = 0, 0

        self.velocityZ = self.velocityZ * (self.platform and self.platform.friction or c.friction)
        self.velocityZ = vars.dvz ~= 0 and vars.dvz or self.velocityZ + vars.dsz
        self.velocityZ = self.velocityZ < c.maxSpeed and self.velocityZ or c.maxSpeed
        self.velocityZ = self.velocityZ > -c.maxSpeed and self.velocityZ or -c.maxSpeed
        vars.dsz, vars.dvz = 0, 0

        self.velocityY = self.gravity and self.velocityY + c.gravity * self.weight or self.velocityY * c.friction
        self.velocityY = vars.dvy ~= 0 and vars.dvy or self.velocityY + vars.dsy
        self.velocityY = self.velocityY < c.maxSpeed and self.velocityY or c.maxSpeed
        self.velocityY = self.velocityY > -c.maxSpeed and self.velocityY or -c.maxSpeed
        self.velocityY = self.platform and self.velocityY > 0 and self.velocityY * -(self.bounce + self.platform.bounce) or self.velocityY
        vars.dsy, vars.dvy = 0, 0

        vars.dx = vars.dx + self.velocityX
        vars.dy = vars.dy + self.velocityY
        vars.dz = vars.dz + self.velocityZ

        if vars.globalY >= 600 then
            local collider = Physix:new({
                bounce = 0.9,
            })
            EventManager:invoke('collide', nil, collider)
        end

        self.platform = nil

    end

    function Physix:collide(collider)
        if self.through then
            self.platform = collider
        end
    end

return Physix