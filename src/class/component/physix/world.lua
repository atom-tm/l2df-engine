--- World component
-- @classmod l2df.class.component.physix.world
-- @author Abelidze
-- @author oniietzschan
-- @author Enrique García Cota
-- @copyright 2014 Enrique García Cota, 2020 Atom-TM

local core = l2df or require(((...):match('(.-)class.+$') or '') .. 'core')
assert(type(core) == 'table' and core.version >= 1.0, 'Physix.World works only with l2df v1.0 and higher')

local helper = core.import 'helper'

local Component = core.import 'class.component'
local Grid = core.import 'class.component.physix.grid'
local Cube = core.import 'class.component.physix.cube'

local setmetatable = _G.setmetatable
local pairs = _G.pairs
local sort = table.sort
local min = helper.min
local max = helper.max
local bound = helper.bound
local newTable = helper.newTable
local freeTable = helper.freeTable

local function sortByWeight(a, b)
    return a.weight < b.weight
end

local function sortByTiAndDistance(a, b)
    if a.ti == b.ti then
        return a.distance < b.distance
    end
    return a.ti < b.ti
end

local function touch(world, col)
    return col.touch.x, col.touch.y, col.touch.z, { }, 0
end

local function cross(world, col, x, y, z, w, h, d, goalX, goalY, goalZ, filter, alreadyVisited)
    return goalX, goalY, goalZ, world:project(col.item, x, y, z, w, h, d, goalX, goalY, goalZ, filter, alreadyVisited)
end

local function slide(world, col, x, y, z, w, h, d, goalX, goalY, goalZ, filter, alreadyVisited)
    goalX = goalX or x
    goalY = goalY or y
    goalZ = goalZ or z

    local tch, move = col.touch, col.move
    if move.x ~= 0 or move.y ~= 0 or move.z ~= 0 then
        if col.normal.x ~= 0 then
            goalX = tch.x
        end
        if col.normal.y ~= 0 then
            goalY = tch.y
        end
        if col.normal.z ~= 0 then
            goalZ = tch.z
        end
    end

    col.slide = {x = goalX, y = goalY, z = goalZ}

    x, y, z = tch.x, tch.y, tch.z
    return goalX, goalY, goalZ, world:project(col.item, x, y, z, w, h, d, goalX, goalY, goalZ, filter, alreadyVisited)
end

local function bounce(world, col, x, y, z, w, h, d, goalX, goalY, goalZ, filter, alreadyVisited)
    goalX = goalX or x
    goalY = goalY or y
    goalZ = goalZ or z

    local tch, move = col.touch, col.move
    local tx, ty, tz = tch.x, tch.y, tch.z
    local bx, by, bz = tx, ty, tz

    if move.x ~= 0 or move.y ~= 0 or move.z ~= 0 then
        local bnx = goalX - tx
        local bny = goalY - ty
        local bnz = goalZ - tz

        if col.normal.x ~= 0 then
            bnx = -bnx
        end
        if col.normal.y ~= 0 then
            bny = -bny
        end
        if col.normal.z ~= 0 then
            bnz = -bnz
        end

        bx = tx + bnx
        by = ty + bny
        bz = tz + bnz
    end

    col.bounce = {x = bx, y = by, z = bz}
    x, y, z = tch.x, tch.y, tch.z
    goalX, goalY, goalZ = bx, by, bz

    return goalX, goalY, goalZ, world:project(col.item, x, y, z, w, h, d, goalX, goalY, goalZ, filter, alreadyVisited)
end

local defaultFilter = function() return 'slide' end

local stack = { }

local World = Component:extend({ unique = true })

    local addItemToCell, removeItemFromCell
    local getDictItemsInCellCube, getCellsTouchedBySegment, getInfoAboutItemsTouchedBySegment, getResponseByName

    ---
    function World.getFromContext()
        return stack[#stack]
    end

    ---
    function World:init(cellSize)
        self.entity = nil
        self.active = true
        self.cellSize = type(cellSize) == 'number' and cellSize or 64

        self.borders = { }
        self.responses = { }

        self:addResponse('touch', touch)
        self:addResponse('cross', cross)
        self:addResponse('slide', slide)
        self:addResponse('bounce', bounce)        
    end

    ---
    function World:added(obj, kwargs)
        if not obj then return false end
        kwargs = kwargs or { }

        self.entity = obj
        self.active = not kwargs.inactive

        local data = self:data(obj)
        self.borders = kwargs.borders or self.borders
        data.cubes = { }
        data.cells = { }
        data.nonEmptyCells = { }
        data.gravity = kwargs.gravity or 0
        data.friction = bound(kwargs.friction, 0, 1) or 0
    end

    ---
    function World:removed(obj)
        local data = self:data(obj)
        data.cubes = nil
        data.cells = nil
        data.nonEmptyCells = nil
        data.gravity = nil

        self.entity = nil
    end

    ---
    function World:data()
        return self.super.data(self, self.entity) or { gravity = 0, friction = 0 }
    end

    ---
    function World:add(item, x, y, z, w, h, d)
        if not self.entity then return end
        local cube = self:data(self.entity).cubes[item]
        if cube then
            error('Item ' .. tostring(item) .. ' added to the world twice.')
        end
        Cube:assert(x, y, z, w, h, d)

        self:data(self.entity).cubes[item] = { x = x, y = y, z = z, w = w, h = h, d = d }

        local cl, ct, cs, cw, ch, cd = Grid:toCellCube(self.cellSize, x, y, z, w, h, d)
        for cz = cs, cs + cd - 1 do
            for cy = ct, ct + ch - 1 do
                for cx = cl, cl + cw - 1 do
                    addItemToCell(self, item, cx, cy, cz)
                end
            end
        end
        return item
    end

    ---
    function World:remove(item)
        if not self.entity then return end
        local x, y, z, w, h, d = self:getCube(item)

        self:data(self.entity).cubes[item] = nil
        local cl, ct, cs, cw, ch, cd = Grid:toCellCube(self.cellSize, x, y, z, w, h, d)
        for cz = cs, cs + cd - 1 do
            for cy = ct, ct + ch - 1 do
                for cx = cl, cl + cw - 1 do
                    removeItemFromCell(self, item, cx, cy, cz)
                end
            end
        end
    end

    ---
    function World:translate(item, x2, y2, z2, w2, h2, d2)
        if not self.entity then return end
        local x1, y1, z1, w1, h1, d1 = self:getCube(item)
        w2 = w2 or w1
        h2 = h2 or h1
        d2 = d2 or d1
        Cube:assert(x2, y2, z2, w2, h2, d2)

        if x1 == x2 and y1 == y2 and z1 == z2 and w1 == w2 and h1 == h2 and d1 == d2 then
            return
        end

        local cl1, ct1, cs1, cw1, ch1, cd1 = Grid:toCellCube(self.cellSize, x1, y1, z1, w1, h1, d1)
        local cl2, ct2, cs2, cw2, ch2, cd2 = Grid:toCellCube(self.cellSize, x2, y2, z2, w2, h2, d2)

        if cl1 ~= cl2 or ct1 ~= ct2 or cs1 ~= cs2 or cw1 ~= cw2 or ch1 ~= ch2 or cd1 ~= cd2 then
            local cr1 = cl1 + cw1 - 1
            local cr2 = cl2 + cw2 - 1
            local cb1 = ct1 + ch1 - 1
            local cb2 = ct2 + ch2 - 1
            local css1 = cs1 + cd1 - 1
            local css2 = cs2 + cd2 - 1
            local cyOut, czOut

            for cz = cs1, css1 do
                czOut = cz < cs2 or cz > css2
                for cy = ct1, cb1 do
                    cyOut = cy < ct2 or cy > cb2
                    for cx = cl1, cr1 do
                        if czOut or cyOut or cx < cl2 or cx > cr2 then
                            removeItemFromCell(self, item, cx, cy, cz)
                        end
                    end
                end
            end

            for cz = cs2, css2 do
                czOut = cz < cs1 or cz > css1
                for cy = ct2, cb2 do
                    cyOut = cy < ct1 or cy > cb1
                    for cx = cl2, cr2 do
                        if czOut or cyOut or cx < cl1 or cx > cr1 then
                            addItemToCell(self, item, cx, cy, cz)
                        end
                    end
                end
            end
        end

        local cube = self:data(self.entity).cubes[item]
        cube.x, cube.y, cube.z, cube.w, cube.h, cube.d = x2, y2, z2, w2, h2, d2
    end

    ---
    function World:move(item, goalX, goalY, goalZ, filter)
        if not self.entity then return end
        local actualX, actualY, actualZ, cols, len = self:check(item, goalX, goalY, goalZ, filter)
        self:translate(item, actualX, actualY, actualZ)
        return actualX, actualY, actualZ, cols, len
    end

    ---
    function World:moveRelative(item, dx, dy, dz, filter)
        if not self.entity then return end
        local x, y, z, w, h, d = self:getCube(item)
        local actualX, actualY, actualZ, cols, len = self:projectMove(item, x, y, z, w, h, d, x + dx, y + dy, z + dz, filter)
        self:translate(item, actualX, actualY, actualZ)
        return actualX - x, actualY - y, actualZ - z, cols, len
    end

    ---
    function World:check(item, goalX, goalY, goalZ, filter)
        if not self.entity then return end
        local x, y, z, w, h, d = self:getCube(item)
        return self:projectMove(item, x, y, z, w, h, d, goalX, goalY, goalZ, filter)
    end

    ---
    function World:queryCube(x, y, z, w, h, d, filter)
        if not self.entity then return end
        Cube:assert(x, y, z, w, h, d)

        local cx, cy, cz, cw, ch, cd = Grid:toCellCube(self.cellSize, x, y, z, w, h, d)
        local dictItemsInCellCube = getDictItemsInCellCube(self, cx, cy, cz, cw, ch, cd)

        local items, len = nil, 0

        local cubes, cube = self:data(self.entity).cubes
        for item, _ in pairs(dictItemsInCellCube) do
            cube = cubes[item]
            if (not filter or filter(item))
            and Cube:isIntersecting(x,y,z,w,h,d, cube.x, cube.y, cube.z, cube.w, cube.h, cube.d)
            then
                len = len + 1
                if items == nil then
                    items = {}
                end
                items[len] = item
            end
        end

        freeTable(dictItemsInCellCube)
        return items, len
    end

    ---
    function World:queryPoint(x, y, z, filter)
        if not self.entity then return end
        local cx, cy, cz = self:toCell(x,y,z)
        local dictItemsInCellCube = getDictItemsInCellCube(self, cx, cy, cz, 1, 1, 1)
        local items, len = { }, 0

        local cubes, cube = self:data(self.entity).cubes
        for item,_ in pairs(dictItemsInCellCube) do
            cube = cubes[item]
            if (not filter or filter(item))
            and Cube:containsPoint(cube.x, cube.y, cube.z, cube.w, cube.h, cube.d, x, y, z)
            then
                len = len + 1
                items[len] = item
            end
        end

        freeTable(dictItemsInCellCube)
        return items, len
    end

    ---
    function World:querySegment(x1, y1, z1, x2, y2, z2, filter)
        if not self.entity then return end
        local itemInfo, len = getInfoAboutItemsTouchedBySegment(self, x1, y1, z1, x2, y2, z2, filter)

        local items = {}
        for i = 1, len do
            items[i] = itemInfo[i].item
        end

        freeTable(itemInfo)
        return items, len
    end

    ---
    function World:querySegmentWithCoords(x1, y1, z1, x2, y2, z2, filter)
        if not self.entity then return end
        local itemInfo, len = getInfoAboutItemsTouchedBySegment(self, x1, y1, z1, x2, y2, z2, filter)
        local dx, dy, dz = x2 - x1, y2 - y1, z2 - z1
        local info, ti1, ti2
        for i = 1, len do
            info = itemInfo[i]
            ti1 = info.ti1
            ti2 = info.ti2

            info.weight = nil
            info.x1 = x1 + dx * ti1
            info.y1 = y1 + dy * ti1
            info.z1 = z1 + dz * ti1
            info.x2 = x1 + dx * ti2
            info.y2 = y1 + dy * ti2
            info.z2 = z1 + dz * ti2
        end
        return itemInfo, len
    end

    ---
    function World:addResponse(name, response)
        -- TODO: add support for callable tables
        self.responses[name] = assert(type(response) == 'function' and response, 'World\'s response must be a function')
    end

    ---
    function World:liftdown()
        stack[#stack + 1] = self
    end

    ---
    function World:liftup()
        if #stack < 1 then return end
        stack[#stack] = nil
    end

    addItemToCell = function (self, item, cx, cy, cz)
        if not self.entity then return end
        local cells = self:data(self.entity).cells
        local nonEmptyCells = self:data(self.entity).nonEmptyCells
        cells[cz] = cells[cz] or { }
        cells[cz][cy] = cells[cz][cy] or setmetatable({ }, {__mode = 'v'})
        if cells[cz][cy][cx] == nil then
            cells[cz][cy][cx] = {
                itemCount = 0,
                x = cx,
                y = cy,
                z = cz,
                items = setmetatable({ }, {__mode = 'k'})
            }
        end

        local cell = cells[cz][cy][cx]
        nonEmptyCells[cell] = true
        if not cell.items[item] then
            cell.items[item] = true
            cell.itemCount = cell.itemCount + 1
        end
    end

    removeItemFromCell = function (self, item, cx, cy, cz)
        if not self.entity then return end
        local cells = self:data(self.entity).cells
        local nonEmptyCells = self:data(self.entity).nonEmptyCells
        if not cells[cz]
            or not cells[cz][cy]
            or not cells[cz][cy][cx]
            or not cells[cz][cy][cx].items[item]
        then
            return false
        end

        local cell = cells[cz][cy][cx]
        cell.items[item] = nil

        cell.itemCount = cell.itemCount - 1
        if cell.itemCount == 0 then
            nonEmptyCells[cell] = nil
        end
        return true
    end

    getDictItemsInCellCube = function (self, cx, cy, cz, cw, ch, cd)
        if not self.entity then return end
        local items_dict = newTable()
        local cells = self:data(self.entity).cells

        for z = cz, cz + cd - 1 do
            local plane = cells[z]
            if plane then
                for y = cy, cy + ch - 1 do
                    local row = plane[y]
                    if row then
                        for x = cx, cx + cw - 1 do
                            local cell = row[x]
                            if cell and cell.itemCount > 0 then -- no cell.itemCount > 1 because tunneling
                                for item,_ in pairs(cell.items) do
                                    items_dict[item] = true
                                end
                            end
                        end
                    end
                end
            end
        end

        return items_dict
    end

    getCellsTouchedBySegment = function (self, x1, y1, z1, x2, y2, z2)
        if not self.entity then return end
        local vcells = self:data(self.entity).cells
        local cells, cellsLen, visited = { }, 0, { }

        Grid:traverse(self.cellSize, x1, y1, z1, x2, y2, z2, function(cx, cy, cz)
            local plane = vcells[cz]
            if not plane then
                return
            end

            local row = plane[cy]
            if not row then
                return
            end

            local cell = row[cx]
            if not cell or visited[cell] then
                return
            end

            visited[cell] = true
            cellsLen = cellsLen + 1
            cells[cellsLen] = cell
        end)

        return cells, cellsLen
    end

    getInfoAboutItemsTouchedBySegment = function (self, x1, y1, z1, x2 ,y2, z2, filter)
        if not self.entity then return end
        local cubes = self:data(self.entity).cubes
        local cells, len = getCellsTouchedBySegment(self, x1, y1, z1, x2, y2, z2)
        local cell, cube, x, y, z, w, h, d, ti1, ti2, tii0, tii1
        local visited, itemInfo, itemInfoLen = newTable(), newTable(), 0

        for i = 1, len do
            cell = cells[i]
            for item in pairs(cell.items) do
                if not visited[item] then
                    visited[item] = true
                    if (not filter or filter(item)) then
                        cube = cubes[item]
                        x, y, z, w, h, d = cube.x, cube.y, cube.z, cube.w, cube.h, cube.d

                        ti1, ti2 = cubeSegmentIntersectionIndices(x, y, z, w, h, d, x1, y1, z1, x2, y2, z2, 0, 1)
                        if ti1 and ((0 < ti1 and ti1 < 1) or (0 < ti2 and ti2 < 1)) then
                            -- the sorting is according to the t of an infinite line, not the segment
                            tii0, tii1 = cubeSegmentIntersectionIndices(x, y, z, w, h, d, x1, y1, z1, x2 ,y2, z2, -math.huge, math.huge)
                            itemInfoLen = itemInfoLen + 1
                            itemInfo[itemInfoLen] = {item = item, ti1 = ti1, ti2 = ti2, weight = min(tii0, tii1)}
                        end
                    end
                end
            end
        end

        freeTable(visited)
        sort(itemInfo, sortByWeight)
        return itemInfo, itemInfoLen
    end

    getResponseByName = function (self, name)
        return assert(self.responses[name], 'Uknown collision type')
        --strformat('Uknown collision type: %s (%s)', name, type(name)))
    end

    function World:projectMove(item, x, y, z, w, h, d, goalX, goalY, goalZ, filter)
        if not self.entity then return end
        filter = filter or defaultFilter

        local projected_cols, projected_len = self:project(item, x, y, z, w, h, d, goalX, goalY, goalZ, filter)

        if projected_len == 0 then
            return goalX, goalY, goalZ, { }, 0
        end

        local cols, len = { }, 0

        local visited = newTable()
        visited[item] = true

        while projected_len > 0 do
            local col = projected_cols[1]
            len       = len + 1
            cols[len] = col

            visited[col.other] = true

            goalX, goalY, goalZ, projected_cols, projected_len = getResponseByName(self, col.type)(
                self, col, x, y, z, w, h, d, goalX, goalY, goalZ, filter, visited
            )
        end

        return goalX, goalY, goalZ, cols, len
    end

    function World:project(item, x, y, z, w, h, d, goalX, goalY, goalZ, filter, alreadyVisited)
        if not self.entity then return end
        Cube:assert(x, y, z, w, h, d)

        goalX = goalX or x
        goalY = goalY or y
        goalZ = goalZ or z
        filter = filter or defaultFilter

        local collisions, len = { }, 0
        local visited = newTable()
        if item ~= nil then
            visited[item] = true
        end

        -- This could probably be done with less cells using a polygon raster over the cells instead of a
        -- bounding cube of the whole movement. Conditional to building a queryPolygon method
        local tx, ty, tz = min(goalX, x), min(goalY, y), min(goalZ, z)
        local tw = max(goalX + w, x + w) - tx
        local th = max(goalY + h, y + h) - ty
        local td = max(goalZ + d, z + d) - tz

        local cx, cy, cz, cw, ch, cd = Grid:toCellCube(self.cellSize, tx, ty, tz, tw, th, td)

        local dictItemsInCellCube = getDictItemsInCellCube(self, cx, cy, cz, cw, ch, cd)

        for other, _ in pairs(dictItemsInCellCube) do
            if not visited[other] and (alreadyVisited == nil or not alreadyVisited[other]) then
                visited[other] = true

                local responseName = filter(item, other)
                if responseName then
                    local ox, oy, oz, ow, oh, od = self:getCube(other)
                    local col = Cube:detectCollision(x,y,z,w,h,d, ox,oy,oz,ow,oh,od, goalX, goalY, goalZ)

                    if col then
                        col.other = other
                        col.item  = item
                        col.type  = responseName

                        len = len + 1
                        collisions[len] = col
                    end
                end
            end
        end
        freeTable(visited)
        freeTable(dictItemsInCellCube)
        if len > 0 then
            sort(collisions, sortByTiAndDistance)
        end
        return collisions, len
    end

    function World:countCells()
        if not self.entity then return end
        local count = 0
        for _, plane in pairs(self:data(self.entity).cells) do
            for _, row in pairs(plane) do
                for _,_ in pairs(row) do
                    count = count + 1
                end
            end
        end
        return count
    end

    function World:hasItem(item)
        return self.entity and not not self:data(self.entity).cubes[item]
    end

    function World:getItems()
        if not self.entity then return end
        local items, len = { }, 0
        for item,_ in pairs(self:data(self.entity).cubes) do
            len = len + 1
            items[len] = item
        end
        return items, len
    end

    function World:countItems()
        if not self.entity then return end
        local len = 0
        for _ in pairs(self:data(self.entity).cubes) do
            len = len + 1
        end
        return len
    end

    function World:getCube(item)
        if not self.entity then return end
        local cube = self:data(self.entity).cubes[item]
        if not cube then
            error('Item ' .. tostring(item) .. ' must be added to the world before getting its cube. Use world:add(item, x,y,z,w,h,d) to add it first.')
        end
        return cube.x, cube.y, cube.z, cube.w, cube.h, cube.d
    end

    function World:toWorld(cx, cy, cz)
        return Grid:toWorld(self.cellSize, cx, cy, cz)
    end

    function World:toCell(x, y, z)
        return Grid:toCell(self.cellSize, x, y, z)
    end

return World