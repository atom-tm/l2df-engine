--- Cube helper
-- @classmod l2df.class.component.physix.cube
-- @author Abelidze
-- @author oniietzschan
-- @author Enrique García Cota
-- @copyright 2014 Enrique García Cota, 2020 Atom-TM

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Physix.Cube works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local abs = math.abs
local min = helper.min
local max = helper.max
local sign = helper.sign
local nearest = helper.nearest

local EPS = 1e-10

local Cube = { }

    function Cube:assert(x, y, z, w, h, l)
        assert(type(x) == 'number', 'x must be a number')
        assert(type(x) == 'number', 'y must be a number')
        assert(type(x) == 'number', 'z must be a number')
        assert(type(w) == 'number' and w > 0, 'w must be a positive number')
        assert(type(h) == 'number' and h > 0, 'h must be a positive number')
        assert(type(l) == 'number' and l > 0, 'l must be a positive number')
    end

    function Cube:nearestCorner(x, y, z, w, h, l, px, py, pz)
        return nearest(px, x, x + w), nearest(py, y, y + h), nearest(pz, z, z + l)
    end

    -- This is a generalized implementation of the liang-barsky algorithm, which also returns
    -- the normals of the sides where the segment intersects.
    -- Returns nil if the segment never touches the cube
    -- Notice that normals are only guaranteed to be accurate when initially ti1, ti2 == -math.huge, math.huge
    function Cube:segmentIntersectionIndices(x, y, z, w, h, d, x1, y1, z1, x2, y2, z2, ti1, ti2)
        ti1, ti2 = ti1 or 0, ti2 or 1
        local dx = x2 - x1
        local dy = y2 - y1
        local dz = z2 - z1
        local nx, ny, nz
        local nx1, ny1, nz1, nx2, ny2, nz2 = 0, 0, 0, 0, 0, 0
        local p, q, r

        for side = 1, 6 do
            if     side == 1 then -- Left
                nx, ny, nz, p, q = -1,  0,  0, -dx, x1 - x
            elseif side == 2 then -- Right
                nx, ny, nz, p, q =  1,  0,  0,  dx, x + w - x1
            elseif side == 3 then -- Top
                nx, ny, nz, p, q =  0, -1,  0, -dy, y1 - y
            elseif side == 4 then -- Bottom
                nx, ny, nz, p, q =  0,  1,  0,  dy, y + h - y1
            elseif side == 5 then -- Front
                nx, ny, nz, p, q =  0,  0, -1, -dz, z1 - z
            else --                  Back
                nx, ny, nz, p, q =  0,  0,  1,  dz, z + d - z1
            end

            if p == 0 then
                if q <= 0 then
                    return nil
                end
            else
                r = q / p
                if p < 0 then
                    if     r > ti2 then
                        return nil
                    elseif r > ti1 then
                        ti1, nx1, ny1, nz1 = r, nx, ny, nz
                    end
                else -- p > 0
                    if     r < ti1 then
                        return nil
                    elseif r < ti2 then
                        ti2, nx2, ny2, nz2 = r, nx, ny, nz
                    end
                end
            end
        end

        return ti1, ti2, nx1, ny1, nz1, nx2, ny2, nz2
    end

    -- Calculates the minkowsky difference between 2 cubes, which is another cube
    function Cube:getDiff(x1, y1, z1, w1, h1, d1, x2, y2, z2, w2, h2, d2)
        return
            x2 - x1 - w1,
            y2 - y1 - h1,
            z2 - z1 - d1,
            w1 + w2,
            h1 + h2,
            d1 + d2
    end

    function Cube:containsPoint(x, y, z, w, h, d, px, py, pz)
        return
            px - x > EPS and
            py - y > EPS and
            pz - z > EPS and
            x + w - px > EPS and
            y + h - py > EPS and
            z + d - pz > EPS
    end

    function Cube:isIntersecting(x1, y1, z1, w1, h1, d1, x2, y2, z2, w2, h2, d2)
        return
            x1 < x2 + w2 and x2 < x1 + w1 and
            y1 < y2 + h2 and y2 < y1 + h1 and
            z1 < z2 + d2 and z2 < z1 + d1
    end

    function Cube:getCubeDistance(x1, y1, z1, w1, h1, d1, x2, y2, z2, w2, h2, d2)
        local dx = x1 - x2 + (w1 - w2) / 2
        local dy = y1 - y2 + (h1 - h2) / 2
        local dz = z1 - z2 + (d1 - d2) / 2
        return (dx * dx) + (dy * dy) + (dz * dz)
    end

    function Cube:detectCollision(x1, y1, z1, w1, h1, d1, x2, y2, z2, w2, h2, d2, goalX, goalY, goalZ)
        goalX = goalX or x1
        goalY = goalY or y1
        goalZ = goalZ or z1

        local dx = goalX - x1
        local dy = goalY - y1
        local dz = goalZ - z1
        local x, y, z, w, h, d = Cube:getDiff(x1, y1, z1, w1, h1, d1, x2, y2, z2, w2, h2, d2)

        local overlaps, ti, nx, ny, nz

        if Cube:containsPoint(x, y, z, w, h, d, 0, 0, 0) then -- item was intersecting other
            local px, py, pz = Cube:nearestCorner(x, y, z, w, h, d, 0, 0, 0)
            -- Volume of intersection:
            local wi = min(w1, abs(px))
            local hi = min(h1, abs(py))
            local di = min(d1, abs(pz))
            ti = wi * hi * di * -1 -- ti is the negative volume of intersection
            overlaps = true
        else
            local ti1, ti2, nx1, ny1, nz1 = Cube:segmentIntersectionIndices(x, y, z, w, h, d, 0, 0, 0, dx, dy, dz, -math.huge, math.huge)

            -- item tunnels into other
            if ti1
            and ti1 < 1
            and (abs(ti1 - ti2) >= EPS) -- special case for cube going through another cube's corner
            and (0 < ti1 + EPS
                or 0 == ti1 and ti2 > 0)
            then
                ti, nx, ny, nz = ti1, nx1, ny1, nz1
                overlaps = false
            end
        end

        if not ti then
            return
        end

        local tx, ty, tz

        if overlaps then
            if dx == 0 and dy == 0 and dz == 0 then
                -- intersecting and not moving - use minimum displacement vector
                local px, py, pz = Cube:nearestCorner(x, y, z, w, h, d, 0, 0, 0)
                if abs(px) <= abs(py) and abs(px) <= abs(pz) then
                    -- X axis has minimum displacement
                    py, pz = 0, 0
                elseif abs(py) <= abs(pz) then
                    -- Y axis has minimum displacement
                    px, pz = 0, 0
                else
                    -- Z axis has minimum displacement
                    px, py = 0, 0
                end
                nx, ny, nz = sign(px), sign(py), sign(pz)
                tx = x1 + px
                ty = y1 + py
                tz = z1 + pz
            else
                -- intersecting and moving - move in the opposite direction
                local ti1, _
                ti1, _, nx, ny, nz = Cube:segmentIntersectionIndices(x, y, z, w, h, d, 0, 0, 0, dx, dy, dz, -math.huge, 1)
                if not ti1 then
                    return
                end
                tx = x1 + dx * ti1
                ty = y1 + dy * ti1
                tz = z1 + dz * ti1
            end
        else -- tunnel
            tx = x1 + dx * ti
            ty = y1 + dy * ti
            tz = z1 + dz * ti
        end

        return {
            overlaps  = overlaps,
            ti        = ti,
            move      = { x = dx, y = dy, z = dz },
            normal    = { x = nx, y = ny, z = nz },
            touch     = { x = tx, y = ty, z = tz },
            distance = Cube:getCubeDistance(x1, y1, z1, w1, h1, d1, x2, y2, z2, w2, h2, d2),
        }
    end

return Cube