--- Grid helper
-- @classmod l2df.class.component.physix.grid
-- @author Abelidze
-- @author oniietzschan
-- @author Enrique García Cota
-- @copyright 2014 Enrique García Cota, 2020 Atom-TM

local abs = math.abs
local ceil = math.ceil
local floor = math.floor

local Grid = { }

    function Grid:toWorld(cellSize, cx, cy, cz)
        return
            (cx - 1) * cellSize,
            (cy - 1) * cellSize,
            (cz - 1) * cellSize
    end

    function Grid:toCell(cellSize, x, y, z)
        return
            floor(x / cellSize) + 1,
            floor(y / cellSize) + 1,
            floor(z / cellSize) + 1
    end

    -- Grid:traverse* functions are based on "A Fast Voxel Traversal Algorithm for Ray Tracing",
    -- by John Amanides and Andrew Woo - http://www.cse.yorku.ca/~amana/research/grid.pdf
    -- It has been modified to include both cells when the ray "touches a grid corner",
    -- and with a different exit condition

    function Grid:traverseInitStep(cellSize, ct, t1, t2)
        local v = t2 - t1
        if v > 0 then
            return 1, cellSize / v, ((ct + v) * cellSize - t1) / v
        elseif v < 0 then
            return -1, -cellSize / v, ((ct + v - 1) * cellSize - t1) / v
        else
            return 0, math.huge, math.huge
        end
    end

    function Grid:traverse(cellSize, x1, y1, z1, x2, y2, z2, f)
        local cx1, cy1, cz1 = Grid:toCell(cellSize, x1, y1, z1)
        local cx2, cy2, cz2 = Grid:toCell(cellSize, x2, y2, z2)
        local stepX, dx, tx = Grid:traverseInitStep(cellSize, cx1, x1, x2)
        local stepY, dy, ty = Grid:traverseInitStep(cellSize, cy1, y1, y2)
        local stepZ, dz, tz = Grid:traverseInitStep(cellSize, cz1, z1, z2)
        local cx, cy, cz = cx1, cy1, cz1

        f(cx, cy, cz)

        -- The default implementation had an infinite loop problem when
        -- approaching the last cell in some occassions. We finish iterating
        -- when we are *next* to the last cell
        while abs(cx - cx2) + abs(cy - cy2) + abs(cz - cz2) > 1 do
            if tx < ty and tx < tz then -- tx is smallest
                tx = tx + dx
                cx = cx + stepX
                f(cx, cy, cz)
            elseif ty < tz then -- ty is smallest
                -- Addition: include both cells when going through corners
                if tx == ty then
                    f(cx + stepX, cy, cz)
                end
                ty = ty + dy
                cy = cy + stepY
                f(cx, cy, cz)
            else -- tz is smallest
                -- Addition: include both cells when going through corners
                if tx == tz then
                    f(cx + stepX, cy, cz)
                end
                if ty == tz then
                    f(cx, cy + stepY, cz)
                end
                tz = tz + dz
                cz = cz + stepZ
                f(cx, cy, cz)
            end
        end

        -- If we have not arrived to the last cell, use it
        if cx ~= cx2 or cy ~= cy2 or cz ~= cz2 then
            f(cx2, cy2, cz2)
        end
    end

    function Grid:toCellCube(cellSize, x, y, z, w, h, d)
        local cx, cy, cz = Grid:toCell(cellSize, x, y, z)
        return
            cx,
            cy,
            cz,
            ceil((x + w) / cellSize) - cx + 1,
            ceil((y + h) / cellSize) - cy + 1,
            ceil((z + d) / cellSize) - cz + 1
    end

return Grid