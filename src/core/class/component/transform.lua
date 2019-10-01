local core = l2df or require(((...):match('(.-)core.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'core.class.component'
local StatesManager = core.import 'core.manager.states'
local EventManager = core.import 'core.manager.event'

local stack = { }

local Transform = Component:extend({ unique = true })

    function Transform:init()
        self.entity = nil
        self.vars = nil
        self.transform = love.math.newTransform()
    end

    function Transform:added(entity, vars)
        if not entity then return false end
        self.entity = entity
        self.vars = vars

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0

        vars.scalex = vars.scalex or 1
        vars.scaley = vars.scaley or 1

        vars.dx = vars.dx or 0
        vars.dy = vars.dy or 0
        vars.dz = vars.dz or 0
        vars.dr = vars.dr or 0

        self.transform:setTransformation(vars.x, vars.y, vars.r)
    end

    function Transform:update()
        self.transform:translate( self.vars.dx, self.vars.dy, self.vars.dx )
        if self.vars.dx > 0 or self.vars.dy > 0 then
            self.vars.dx = 0
            self.vars.dy = 0
            print( self.transform:getMatrix( ))
        end
    end

    function Transform:push()
        stack[#stack + 1] = self.transform
    end

    function Transform:pop()
        stack[#stack] = nil
    end

return Transform