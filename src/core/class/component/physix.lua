--- Physics component
-- @classmod l2df.core.class.component.physix
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'core.class.component'
local EventManager = core.import 'core.manager.event'
local Settings = core.import 'core.manager.settings'
local helper = core.import 'helper'
local abs = math.abs

local Physix = Component:extend({ unique = true })

    local stack = { }

    Physix.Controller = Component:extend({ unique = true })
    function Physix.Controller:init(...)
        self:set(...)
    end

    function Physix.Controller:set(kwargs)
        kwargs = kwargs or { }
        self.gravity = kwargs.gravity or Settings.physics.gravity or 0
        self.maxSpeed = kwargs.maxSpeed or Settings.physics.maxSpeed or 0
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
        self.weight = helper.bound(kwargs.weight, 0, 10) and kwargs.weight or 1
        self.bounce = helper.bound(kwargs.bounce, 0, 1) and kwargs.bounce or 0
        self.friction = helper.bound(kwargs.friction, 0, 1) and kwargs.friction or 0.9

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

    function Physix:update(dt)
        local vars = self.vars
        local world = stack[#stack]

        self.velocityX = vars.dvx ~= 0 and convert(vars.dvx)
        or self.velocityX - convert(self.velocityX * 0.1) * dt

        vars.dvx = 0

        vars.dx = vars.dx + self.velocityX







        --[[self.velocityX = self.velocityX * (self.platform and self.platform.friction or 1) * c.friction
        self.velocityX = vars.dvx ~= 0 and vars.dvx or self.velocityX + vars.dsx + c.wind
        self.velocityX = self.velocityX < c.maxSpeed and self.velocityX or c.maxSpeed
        self.velocityX = self.velocityX > -c.maxSpeed and self.velocityX or -c.maxSpeed
        vars.dsx, vars.dvx = 0, 0

        self.velocityZ = self.velocityZ * (self.platform and self.platform.friction or c.friction)
        self.velocityZ = vars.dvz ~= 0 and vars.dvz or self.velocityZ + vars.dsz
        self.velocityZ = self.velocityZ < c.maxSpeed and self.velocityZ or c.maxSpeed
        self.velocityZ = self.velocityZ > -c.maxSpeed and self.velocityZ or -c.maxSpeed
        vars.dsz, vars.dvz = 0, 0]]

        --[[self.velocityY = vars.dvy ~= 0 and vars.dvy
        or vars.dsy ~= 0 and self.velocityY + vars.dsy
        or self.gravity and self.velocityY + (c.gravity * self.weight)
        or self.velocityY
        self.velocityY = self.velocityY * c.friction

        self.velocityY = c.maxSpeed ~= 0 and (self.velocityY < c.maxSpeed and self.velocityY or c.maxSpeed) or self.velocityY
        self.velocityY = c.maxSpeed ~= 0 and (self.velocityY > -c.maxSpeed and self.velocityY or -c.maxSpeed) or self.velocityY

        self.velocityY = p and self.velocityY > 0 and self.velocityY * -(self.bounce + p.bounce) or self.velocityY
        self.velocityY = abs(self.velocityY) < 0.001 and 0 or self.velocityY

        print(self.velocityY)

        vars.dsy, vars.dvy = 0, 0

        vars.dx = vars.dx + self.velocityX
        vars.dy = vars.dy + self.velocityY
        vars.dz = vars.dz + self.velocityZ

        self.platform = nil
        if vars.globalY >= 600 then
            self.platform = Physix:new()
            vars.y = 600
        end]]
    end

    function convert(x)
        return x * 60
    end

return Physix