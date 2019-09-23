local core = l2df or require((...):match("(.-)core.+$") or "" .. "core")
assert(type(core) == "table" and core.version >= 1.0, "Components works only with l2df v1.0 and higher")

local Component = core.import "core.class.component"

local Event = core.import "core.manager.event"
local RenderManager = core.import "core.manager.render"
local ResourseManager = core.import "core.manager.resourse"

local Render = Component:extend({ unique = true })

    function Render:init()
        self.entity = nil
    end

    function Render:added(entity, vars, sprites)
        if not entity then return false end
        self.entity = entity
        self.vars = vars
        sprites = sprites or { }
        if type(sprites) == 'string' then
            sprites = { { ResourseManager:load(sprites) } }
        end

        vars.x = vars.x or 0
        vars.y = vars.y or 0
        vars.z = vars.z or 0
        vars.r = vars.r or 0

        vars.scalex = vars.scalex or 1
        vars.scaley = vars.scaley or 1

        vars.offsetx = vars.offsetx or 0
        vars.offsety = vars.offsety or 0

        vars.hidden = vars.hidden or false
        vars.pic = vars.pic or 1

        self.pics = { }
        local s = nil
        for i = 1, #sprites do
            s = sprites[i]
            s[1] = type(s[1]) == 'string' and ResourseManager:load(s[1])
            self:addPics(s[1], s[2], s[3], s[4], s[5], s[6], s[7], s[8], s[9])
        end

        Event:subscribe("update", self.update, nil, self)
    end


    --- The function adds "sprites" to the entity using a sprite list or a whole image
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
                    --f = f - 1
                    s = s + 1
                    self.pics[s] = RenderManager:generateQuad(spritelist, xo * w, yo * h, w, h)
                    if f <= 0 then return end
                end
            end
        else
            s = x and x <= #self.pics and x or #self.pics + 1
            self.pics[s] = { spritelist }
        end
    end


    function Render:update()
        if not self.hidden then
            RenderManager:add(self.pics[self.vars.pic], self.vars.x, self.vars.y)
        end
    end

return Render