--- Physics component
-- @classmod l2df.core.class.component.physix
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'
local EventManager = core.import 'manager.event'
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
        self.gravity = kwargs.gravity or 0.98
        self.maxSpeed = kwargs.maxSpeed or 0
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
    end

    function Physix:added(entity)
        if not entity then return false end

        self.entity = entity
        local vars = entity.vars
        vars.vx = vars.vx or 0
        vars.vy = vars.vy or 0
        vars.vz = vars.vz or 0
        vars.dx = vars.dx or 0
        vars.dy = vars.dy or 0
        vars.dz = vars.dz or 0
        vars.dvx = vars.dvx or 0
        vars.dvy = vars.dvy or 0
        vars.dvz = vars.dvz or 0
        vars.dsx = vars.dsx or 0
        vars.dsy = vars.dsy or 0
        vars.dsz = vars.dsz or 0
        return true
    end

    function Physix:update(dt)
        if not self.entity then return end

        local vars = self.entity.vars
        local c = stack[#stack]
        local p = self.platform

        -- vars.vx = vars.vx * (self.platform and self.platform.friction or 1) * c.friction
        -- vars.vx = vars.dvx ~= 0 and vars.dvx or vars.vx + vars.dsx + c.wind
        -- vars.vx = vars.vx < c.maxSpeed and vars.vx or c.maxSpeed
        -- vars.vx = vars.vx > -c.maxSpeed and vars.vx or -c.maxSpeed
        -- vars.dsx, vars.dvx = 0, 0

        -- vars.vz = vars.vz * (self.platform and self.platform.friction or c.friction)
        -- vars.vz = vars.dvz ~= 0 and vars.dvz or vars.vz + vars.dsz
        -- vars.vz = vars.vz < c.maxSpeed and vars.vz or c.maxSpeed
        -- vars.vz = vars.vz > -c.maxSpeed and vars.vz or -c.maxSpeed
        -- vars.dsz, vars.dvz = 0, 0

        vars.vy = vars.dvy ~= 0 and vars.dvy
        or vars.dsy ~= 0 and vars.vy + vars.dsy
        or self.gravity and vars.vy + (c.gravity * self.weight)
        or vars.vy
        vars.vy = vars.vy * c.friction

        vars.vy = c.maxSpeed ~= 0 and (vars.vy < c.maxSpeed and vars.vy or c.maxSpeed) or vars.vy
        vars.vy = c.maxSpeed ~= 0 and (vars.vy > -c.maxSpeed and vars.vy or -c.maxSpeed) or vars.vy

        vars.vy = p and vars.vy > 0 and vars.vy * -(self.bounce + p.bounce) or vars.vy
        vars.vy = abs(vars.vy) < 0.001 and 0 or vars.vy

        vars.dsy, vars.dvy = 0, 0

        vars.dx = vars.dx + vars.vx
        vars.dy = vars.dy + vars.vy
        vars.dz = vars.dz + vars.vz

        self.platform = nil
        if vars.globalY >= 600 then
            self.platform = Physix:new()
            vars.y = 600
        end
    end

return Physix