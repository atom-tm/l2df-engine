local core = l2df or require((...):match('(.-)core.+$') or '' .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Components works only with l2df v1.0 and higher')

local Component = core.import 'core.class.component'

local Event = core.import 'core.manager.event'
local RenderManager = core.import 'core.manager.render'
local ResourceManager = core.import 'core.manager.resource'

local Render = Component:extend({ unique = true })

    function Render:init()
        self.entity = nil
        self.ox = 0
        self.oy = 0
        self.kx = 0
        self.ky = 0
        self.color = { 1,1,1,1 }
    end

    function Render:added(entity, vars, sprites)
        if not entity then return false end
        self.entity = entity
        self.vars = vars
        sprites = sprites or { }
        if type(sprites) == 'string' then
            sprites = { { res = ResourceManager:load(sprites) } }
        end

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0

        vars.scaleX = vars.scaleX or 1
        vars.scaleY = vars.scaleY or 1

        vars.centerX = vars.centerX or 0
        vars.centerY = vars.centerY or 0

        vars.hidden = vars.hidden or false
        vars.pic = vars.pic or 1

        self.pics = { }
        local s = nil
        for i = 1, #sprites do
            s = sprites[i]
            s.res = type(s.res) == 'string' and ResourceManager:load(s.res) or s.res
            self:addPics(s.res, s.x, s.y, s.w, s.h, s.s, s.f, s.xo, s.yo)
        end
    end


    --- This function adds 'sprites' to the entity using a sprite list or a whole image
    --  @tparam Drawable spritelist
    --  @tparam number x the number of cells in a sheet horizontally
    --  @tparam number y number of vertical sheet cells
    --  @tparam number w width of one sheet cell
    --  @tparam number h height of one sheet cell
    --  @tparam number s starting point of recording in the sprite array
    --  @tparam number f number of frames entered
    --  @tparam number xo x offset
    --  @tparam number yo y offset
    function Render:addPics(spritelist, x, y, w, h, s, f, xo, yo)
        if not spritelist then return end
        if x and y then
            xo = xo or 0
            yo = yo or 0
            w = w or 0
            h = h or 0
            s = s and s <= #self.pics and s or #self.pics
            f = f or (x - xo) * (y - yo)
            for yo = yo, y - 1 do
                for xo = xo, x - 1 do
                    f = f - 1
                    s = s + 1
                    self.pics[s] = RenderManager:generateQuad(spritelist, xo * w, yo * h, w, h)
                    if f <= 0 then return end
                end
            end
        else
            s = x and x <= #self.pics and x or #self.pics + 1
            self.pics[s] = RenderManager:generateQuad(spritelist)
        end
    end


    function Render:postUpdate()
        local vars = self.vars
        if not vars.hidden then
            RenderManager:add({
                object = self.pics[self.vars.pic][1],
                quad = self.pics[self.vars.pic][2],
                index = vars.globalZ or vars.z,
                x = vars.globalX or vars.x,
                y = vars.globalY or vars.y,
                r = vars.globalR or vars.r,
                sx = vars.globalScaleX or vars.scaleX,
                sy = vars.globalScaleY or vars.scaleY,
                ox = self.ox + vars.centerX,
                oy = self.oy + vars.centerY,
                kx = self.kx,
                ky = self.ky,
                color = self.color
            })
        end
    end

return Render