--- Grid helper.
-- @classmod l2df.class.component.physix.grid
-- @author Abelidze
-- @author oniietzschan
-- @author Enrique García Cota
-- @copyright 2014 Enrique García Cota, 2020 Atom-TM

local abs = math.abs
local ceil = math.ceil
local floor = math.floor

local Grid = { }

    --- Get left-top corner cell coordinates.
    -- @param number cellsize  Size of the cell in pixels.
    -- @param number cx  Cell X index.
    -- @param number cy  Cell Y index.
    -- @param number cz  Cell Z index.
    -- @return number  X coordinate.
    -- @return number  Y coordinate.
    -- @return number  Z coordinate.
    function Grid:toWorld(cellsize, cx, cy, cz)
        return
            (cx - 1) * cellsize,
            (cy - 1) * cellsize,
            (cz - 1) * cellsize
    end

    --- Convert left-top corner cell coordinates to cell indexes.
    -- @param number cellsize  Size of the cell in pixels.
    -- @param number x  X coordinate.
    -- @param number y  Y coordinate.
    -- @param number z  Z coordinate.
    -- @return number  Cell X index.
    -- @return number  Cell Y index.
    -- @return number  Cell Z index.
    function Grid:toCell(cellsize, x, y, z)
        return
            floor(x / cellsize) + 1,
            floor(y / cellsize) + 1,
            floor(z / cellsize) + 1
    end

    --- Convert cube from world to cell coordinates.
    -- @param number cellsize  Size of the cell in pixels.
    -- @param number x  Cube X coordinate.
    -- @param number y  Cube Y coordinate.
    -- @param number z  Cube Z coordinate.
    -- @param number w  Cube width.
    -- @param number h  Cube height.
    -- @param number d  Cube depth.
    -- @return number  Cell X index.
    -- @return number  Cell Y index.
    -- @return number  Cell Z index.
    -- @return number  Cell width.
    -- @return number  Cell height.
    -- @return number  Cell depth.
    function Grid:toCellCube(cellsize, x, y, z, w, h, d)
        local cx, cy, cz = Grid:toCell(cellsize, x, y, z)
        return
            cx,
            cy,
            cz,
            ceil((x + w) / cellsize) - cx + 1,
            ceil((y + h) / cellsize) - cy + 1,
            ceil((z + d) / cellsize) - cz + 1
    end

    local function traverseInitStep(cellsize, ct, t1, t2)
        local v = t2 - t1
        if v > 0 then
            return 1, cellsize / v, ((ct + v) * cellsize - t1) / v
        elseif v < 0 then
            return -1, -cellsize / v, ((ct + v - 1) * cellsize - t1) / v
        else
            return 0, math.huge, math.huge
        end
    end

    --- Function is based on "A Fast Voxel Traversal Algorithm for Ray Tracing",
    -- by John Amanides and Andrew Woo - http://www.cse.yorku.ca/~amana/research/grid.pdf
    -- It has been modified to include both cells when the ray "touches a grid corner",
    -- and with a different exit condition.
    -- @param number cellsize  Size of the cell in pixels.
    -- @param number x1  Start X coordinate.
    -- @param number y1  Start Y coordinate.
    -- @param number z1  Start Z coordinate.
    -- @param number x2  End X coordinate.
    -- @param number y2  End Y coordinate.
    -- @param number z2  End Z coordinate.
    -- @param function f  Traverse function called for each cell in path.
    function Grid:traverse(cellsize, x1, y1, z1, x2, y2, z2, f)
        local cx1, cy1, cz1 = Grid:toCell(cellsize, x1, y1, z1)
        local cx2, cy2, cz2 = Grid:toCell(cellsize, x2, y2, z2)
        local stepX, dx, tx = traverseInitStep(cellsize, cx1, x1, x2)
        local stepY, dy, ty = traverseInitStep(cellsize, cy1, y1, y2)
        local stepZ, dz, tz = traverseInitStep(cellsize, cz1, z1, z2)
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

return Grid