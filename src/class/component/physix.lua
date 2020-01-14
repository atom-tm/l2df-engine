--- Physics component
-- @classmod l2df.class.component.physix
-- @author Kasai
-- @copyright Atom-TM 2019

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'class.component'
local EventManager = core.import 'manager.event'
local helper = core.import 'helper'
local bound = helper.bound
local abs = math.abs

local function convert(x)
    return x * 60
end

local Physix = Component:extend({ unique = true })

    local stack = { }

    Physix.World = Component:extend({ unique = true })
    function Physix.World:init(...)
        self:set(...)
    end

    function Physix.World:set(kwargs)
        kwargs = kwargs or { }
        self.gravity = kwargs.gravity or 0
        self.maxSpeed = kwargs.maxSpeed or 0
        self.friction = bound(self.friction, 0,1) or 0
    end

    function Physix.World:push()
        stack[#stack + 1] = self
    end

    function Physix.World:pop()
        if #stack < 2 then return end
        stack[#stack] = nil
    end

    stack = { Physix.World:new({
        gravity = 9.8,
        maxSpeed = 0,
        friction = 100
    }) }


    function Physix:init(...)
        self.entity = nil
        self.platform = nil
    end

    function Physix:added(entity, kwargs)
        if not entity then return false end
        kwargs = kwargs or { }

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
        vars.mx = vars.mx or 0
        vars.my = vars.my or 0
        vars.mz = vars.mz or 0

        vars.gravity = kwargs.gravity or false
        vars.static = kwargs.static or false

        return true
    end

    function Physix:update(dt)
        if not self.entity then return end

        local vars = self.entity.vars
        local world = stack[#stack]

        if vars.static then return end

        vars.vx = vars.vx - convert(vars.vx * world.friction) * dt
        vars.vx = vars.dvx ~= 0 and convert(vars.dvx) or vars.vx
        vars.vx = vars.vx + convert(vars.dsx)

        vars.vy = vars.vy + (convert(vars.gravity and world.gravity or vars.vy * world.friction)) * dt
        vars.vy = vars.dvy ~= 0 and convert(vars.dvy) or vars.vy
        vars.vy = vars.vy + convert(vars.dsy)

        vars.vz = vars.vz - convert(vars.vz * world.friction) * dt
        vars.vz = vars.dvz ~= 0 and convert(vars.dvz) or vars.vz
        vars.vz = vars.vz + convert(vars.dsz)

        vars.mx = convert(vars.dx) + vars.vx
        vars.my = convert(vars.dy) + vars.vy
        vars.mz = convert(vars.dz) + vars.vz

        vars.dsx, vars.dvx, vars.dx = 0, 0, 0
        vars.dsy, vars.dvy, vars.dy = 0, 0, 0
        vars.dsz, vars.dvz, vars.dz = 0, 0, 0


        -- local p = self.platform
        -- vars.vy = vars.dvy ~= 0 and vars.dvy
        -- or vars.dsy ~= 0 and vars.vy + vars.dsy
        -- or self.gravity and vars.vy + (c.gravity * self.weight)
        -- or vars.vy
        -- vars.vy = vars.vy * c.friction

        -- vars.vy = c.maxSpeed ~= 0 and (vars.vy < c.maxSpeed and vars.vy or c.maxSpeed) or vars.vy
        -- vars.vy = c.maxSpeed ~= 0 and (vars.vy > -c.maxSpeed and vars.vy or -c.maxSpeed) or vars.vy

        -- vars.vy = p and vars.vy > 0 and vars.vy * -(self.bounce + p.bounce) or vars.vy
        -- vars.vy = abs(vars.vy) < 0.001 and 0 or vars.vy

        -- vars.dsy, vars.dvy = 0, 0

        -- vars.dx = vars.dx + vars.vx
        -- vars.dy = vars.dy + vars.vy
        -- vars.dz = vars.dz + vars.vz

        -- self.platform = nil
        -- if vars.globalY >= 600 then
        --     self.platform = Physix:new()
        --     vars.y = 600
        -- end
    end

return Physix