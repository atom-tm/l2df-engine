--- World component.
-- <p>This would be suppressed and removed in future.</p>
-- <p>Inherited from @{l2df.class.component|l2df.class.Component} class.</p>
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
local Renderer = core.import 'manager.render'

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

    --- The info contained on every collision item.
    -- Most of this info is useful only if you are doing semi-advanced stuff with collisions, but they could have some uses.
    -- @field mixed item  The item being moved / checked.
    -- @field mixed other  An item colliding with the item being moved.
    -- @field string type  The result of `filter(other)`. It's usually "touch", "cross", "slide" or "bounce".
    -- @field boolean overlaps  True if item "was overlapping" other when the collision started. False if it didn't but "tunneled" through other.
    -- @field number ti  Number between 0 and 1. How far along the movement to the goal did the collision occur.
    -- @field {x=number,y=number,z=number} move  The difference between the original coordinates and the actual ones.
    -- @field {x=number,y=number,z=number} normal  The collision normal; usually -1, 0, or 1 in x, y, and z.
    -- @field {x=number,y=number,z=number} touch  The coordinates where item started touching other.
    -- @field {x=number,y=number,z=number,w=number,h=number,d=number} itemCube  The cube item occupied when the touch happened.
    -- @field {x=number,y=number,z=number,w=number,h=number,d=number} otherCube  The cube other occupied when the touch happened.
    -- @table .CollisionInfo

    --- World initialization.
    -- @param[opt=64] number cellsize  Size of the cell in pixels for spatial hashing.
    function World:init(cellsize)
        self.entity = nil
        self.active = true
        self.cellSize = type(cellsize) == 'number' and cellsize or 64

        self.borders = { }
        self.responses = { }

        self:addResponse('touch', touch)
        self:addResponse('cross', cross)
        self:addResponse('slide', slide)
        self:addResponse('bounce', bounce)        
    end

    --- Component was added to @{l2df.class.entity|Entity} event.
    -- Adds `"world"` key to the @{l2df.class.entity.C|Entity.C} table.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @param[opt] table kwargs  Keyword arguments.
    -- @param[opt] {l2df.manager.render.Light,...} kwargs.lights  Array of lights used for drop shadows. Empty by default.
    -- @param[opt] {x1=number,x2=number,y1=number,y2=number,z1=number,z2=number} kwargs.borders  Borders of the world.
    -- It's a global BBox restricting area of entities movement (if they use @{l2df.manager.physix.move|PhysixManager:move()}).
    -- @param[opt] string kwargs.layer  @{l2df.manager.render.addLayer|Layer} for drawing. Careful: if setted it will change entity's `layer`.
    -- @param[opt] number kwargs.depth  Depth of the world in px. Used for spatial hashing.
    -- @param[opt=0] number kwargs.width  Width of the world in px. Used for spatial hashing.
    -- @param[opt=0] number kwargs.height  Height of the world in px. Used for spatial hashing.
    -- @param[opt=0] number kwargs.gravity  Gravity acceleration used in the world.
    -- @param[opt=0] number kwargs.friction  Friction used in the world. Value is bounded at [0; 1] segment.
    -- @param[opt=1] number kwargs.zoom  Default game's zoom. Used by @{l2df.class.component.camera|Camera}.
    -- @param[opt=false] boolean kwargs.inactive  If true the world would not receive update events.
    function World:added(obj, kwargs)
        if not obj then return false end
        kwargs = kwargs or { }

        self.entity = obj
        self.active = not kwargs.inactive
        obj.C.world = self:wrap(obj)

        local data = self:data(obj)
        self.borders = kwargs.borders or self.borders
        data.width = kwargs.width or 0
        data.height = kwargs.height or 0
        data.depth = kwargs.depth
        data.layer = kwargs.layer
        data.lights = kwargs.lights or { }
        data.zoom = kwargs.zoom or 1
        data.cubes = { }
        data.cells = { }
        data.nonEmptyCells = { }
        data.gravity = kwargs.gravity or 0
        data.friction = bound(kwargs.friction, 0, 1) or 0
    end

    --- Component was removed from @{l2df.class.entity|Entity} event.
    -- Removes `"world"` key from @{l2df.class.entity.C|Entity.C} table.
    -- @param l2df.class.entity obj  Entity's instance.
    function World:removed(obj)
        local data = self:data(obj)
        data.cubes = nil
        data.cells = nil
        data.nonEmptyCells = nil
        data.gravity = nil
        obj.C.world = nil
        self.entity = nil
    end

    function World:data(obj)
        return self.super.data(self, obj) or { gravity = 0, friction = 0 }
    end

    --- Static function for getting current world in stack.
    -- Should be called during `"pre-update"`, `"update"` or `"post-update"` events only.
    -- @return l2df.class.component.physix.world  World component @{l2df.class.component.wrap|wrapped} with its parent @{l2df.class.entity|entity}.
    function World.getFromContext()
        return stack[#stack]
    end

    --- Component post-update event handler.
    -- @param l2df.class.entity obj  Entity's instance.
    -- @param number dt  Delta-time since last game tick.
    -- @param boolean islast  Processes only the last drawn frame.
    function World:update(obj, dt, islast)
        if not (obj and islast) then return end
        local data = self:data(obj)
        Renderer:updateLayerWorld(data.layer, data.width, data.height, data.depth, data.zoom)
    end

    --- Component liftdown event handler.
    -- @param l2df.class.entity obj  Entity's instance.
    function World:liftdown(obj)
        stack[#stack + 1] = self:wrap(obj)
    end

    --- Component liftup event handler.
    -- @param l2df.class.entity obj  Entity's instance.
    function World:liftup(obj)
        if #stack < 1 then return end
        stack[#stack] = nil
    end

    --- Adding items to the world.
    -- Throws error if an item already exists.
    -- @param mixed item  New item being inserted and linked with the provided BBox.
    -- Usually it is a table but also can be an object of any lua type except of userdata.
    -- When world is added as a component item might be an instance of the @{l2df.class.entity|Entity} class.
    -- @param number x  BBox X position.
    -- @param number y  BBox Y position.
    -- @param number z  BBox Z position.
    -- @param number w  BBox width.
    -- @param number h  BBox height.
    -- @param number d  BBox depth.
    -- @return mixed  An added item.
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

    --- Removing items from the world.
    -- @param mixed item  Must be something previously inserted in the world with @{l2df.class.component.physix.world.add|World:add}.
    -- If this is not the case, function will raise an error.
    -- When world is added as a component item might be an instance of the @{l2df.class.entity|Entity} class.
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

    --- Changing the position and dimensions of items in the world.
    -- Even if your "player" has attributes like `player.x`, `player.y`, and `player.z`, changing those will not automatically change them inside world.
    -- `translate` is one of the ways to do so: it changes the cube representing item inside world.
    -- This method always changes the cube associated to item, ignoring all collisions
    -- (use @{l2df.class.component.physix.world.move|World:move()} for that). It returns nothing.
    -- @param mixed item  Must be something previously inserted in the world with @{l2df.class.component.physix.world.add|World:add}.
    -- If this is not the case, function will raise an error.
    -- When world is added as a component item might be an instance of the @{l2df.class.entity|Entity} class.
    -- @param number x2  New BBox X position.
    -- @param number y2  New BBox Y position.
    -- @param number z2  New BBox Z position.
    -- @param number w2  New BBox width.
    -- @param number h2  New BBox height.
    -- @param number d2  New BBox depth.
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

    --- Moving an item in the world, with collision resolution.
    -- `goalX`, `goalY`, `goalZ` are the desired `x`, `y`, and `z` coordinates.
    -- The item will end up in those coordinates if it doesn't collide with anything.
    -- If, however, it collides with 1 or more other items, it can end up in a different set of coordinates.
    -- @param mixed item  Must be something previously inserted in the world with @{l2df.class.component.physix.world.add|World:add}.
    -- If this is not the case, function will raise an error.
    -- When world is added as a component item might be an instance of the @{l2df.class.entity|Entity} class.
    -- @param number goalX  The desired X coordinate.
    -- @param number goalY  The desired Y coordinate.
    -- @param number goalZ  The desired Z coordinate.
    -- @param[opt] function filter  If provided, it must have this signature: `local type = filter(item, other)`.
    -- `type` is a value which defines how `item` collides with `other`.
    -- If `type` is `false` or `nil`, `item` will ignore `other` completely (there will be no collision).
    -- If `type` is `"touch"`, `"cross"`, `"slide"` or `"bounce"`, `item` will respond to the collisions in different ways.
    -- By default, filter always returns "slide".
    -- @return number  Actual X position where the object ended up after colliding with other objects in the world.
    -- @return number  Actual Y position where the object ended up after colliding with other objects in the world.
    -- @return number  Actual Z position where the object ended up after colliding with other objects in the world.
    -- @return {l2df.class.component.physix.world.CollisionInfo,...}  Array of all the collisions that were detected.
    -- @return number  The amount of collisions produced.
    function World:move(item, goalX, goalY, goalZ, filter)
        if not self.entity then return end
        local actualX, actualY, actualZ, cols, len = self:check(item, goalX, goalY, goalZ, filter)
        self:translate(item, actualX, actualY, actualZ)
        return actualX, actualY, actualZ, cols, len
    end

    --- Same as @{l2df.class.component.physix.world.move|World:move()} but uses a difference vector instead of goal position.
    -- @param mixed item  Must be something previously inserted in the world with @{l2df.class.component.physix.world.add|World:add}.
    -- If this is not the case, function will raise an error.
    -- When world is added as a component item might be an instance of the @{l2df.class.entity|Entity} class.
    -- @param number dx  Difference between current item's X coordinate and its goal X position.
    -- @param number dy  Difference between current item's Y coordinate and its goal Y position.
    -- @param number dz  Difference between current item's Z coordinate and its goal Z position.
    -- @param[opt] function filter  Filter function. For more info see @{l2df.class.component.physix.world.move|World:move()}.
    -- @return number  Difference between actual X position where the object ended up and item's X position before movement.
    -- @return number  Difference between actual Y position where the object ended up and item's Y position before movement.
    -- @return number  Difference between actual Z position where the object ended up and item's Z position before movement.
    -- @return {l2df.class.component.physix.world.CollisionInfo,...}  Array of all the collisions that were detected.
    -- @return number  The amount of collisions produced.
    function World:moveRelative(item, dx, dy, dz, filter)
        if not self.entity then return end
        local x, y, z, w, h, d = self:getCube(item)
        local actualX, actualY, actualZ, cols, len = self:projectMove(item, x, y, z, w, h, d, x + dx, y + dy, z + dz, filter)
        self:translate(item, actualX, actualY, actualZ)
        return actualX - x, actualY - y, actualZ - z, cols, len
    end

    --- Checking for collisions without moving.
    -- @param mixed item  Must be something previously inserted in the world with @{l2df.class.component.physix.world.add|World:add}.
    -- If this is not the case, function will raise an error.
    -- When world is added as a component item might be an instance of the @{l2df.class.entity|Entity} class.
    -- @param number goalX  The desired X coordinate.
    -- @param number goalY  The desired Y coordinate.
    -- @param number goalZ  The desired Z coordinate.
    -- @param[opt] function filter  Filter function. For more info see @{l2df.class.component.physix.world.move|World:move()}.
    -- @return number  Actual X position where the object ended up after colliding with other objects in the world.
    -- @return number  Actual Y position where the object ended up after colliding with other objects in the world.
    -- @return number  Actual Z position where the object ended up after colliding with other objects in the world.
    -- @return {l2df.class.component.physix.world.CollisionInfo,...}  Array of all the collisions that were detected.
    -- @return number  The amount of collisions produced.
    function World:check(item, goalX, goalY, goalZ, filter)
        if not self.entity then return end
        local x, y, z, w, h, d = self:getCube(item)
        return self:projectMove(item, x, y, z, w, h, d, goalX, goalY, goalZ, filter)
    end

    --- Returns the items that touch a given point.
    -- It is useful for things like clicking with the mouse and getting the items affected.
    -- @param number x  X coordinate of the point that is being checked.
    -- @param number y  Y coordinate of the point that is being checked.
    -- @param number z  Z coordinate of the point that is being checked.
    -- @param[opt] function filter  Function which takes one parameter (an item).
    -- `queryPoint` will not return the items that return `false` or `nil` on `filter(item)`.
    -- By default, all items touched by the point are returned.
    -- @return {mixed,...}  List of the items from the ones inserted on the world (like player) that contain the point `x`, `y`, `z`.
    -- If no items touch the point, then items will be an empty table. If not empty, then the order of these items is random.
    -- @return number  Length of the items list. It is equivalent to `#items`, but it's slightly faster to use instead.
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

    --- Returns the items that touch a given cube.
    -- Useful for things like selecting what to display on the screen or selecting a group of units with the mouse in a strategy game.
    -- @param number x  BBox X position.
    -- @param number y  BBox Y position.
    -- @param number z  BBox Z position.
    -- @param number w  BBox width.
    -- @param number h  BBox height.
    -- @param number d  BBox depth.
    -- @param[opt] function filter  When provided, it is used to "filter out" which items are returned.
    -- If `filter(item)` returns `false` or `nil`, that item is ignored. By default, all items are included.
    -- @return {mixed,...}  List of items, like in @{l2df.class.component.physix.world.queryPoint|World:queryPoint()}.
    -- @return number  Equivalent to `#items`
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

    --- Returns the items that touch a segment.
    -- It's useful for things like line-of-sight or modelling bullets or lasers.
    -- @param number x1  X coordinate of the segment's start.
    -- @param number y1  Y coordinate of the segment's start.
    -- @param number z1  Z coordinate of the segment's start.
    -- @param number x2  X coordinate of the segment's end.
    -- @param number y2  Y coordinate of the segment's end.
    -- @param number z2  Z coordinate of the segment's end.
    -- @param[opt] function filter  When provided, it is used to "filter out" which items are returned.
    -- If `filter(item)` returns `false` or `nil`, that item is ignored. By default, all items are included.
    -- @return {mixed,...}  List of items, like in @{l2df.class.component.physix.world.queryPoint|World:queryPoint()},
    -- but sorted by proximity (from the closest to `x1`, `y1`, `z1` to the farest).
    -- @return number  Equivalent to `#items`.
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

    --- An extended version of @{l2df.class.component.physix.world.querySegment|World:querySegment()}
    -- which returns the collision points of the segment with the items, in addition to the items.
    -- @param number x1  X coordinate of the segment's start.
    -- @param number y1  Y coordinate of the segment's start.
    -- @param number z1  Z coordinate of the segment's start.
    -- @param number x2  X coordinate of the segment's end.
    -- @param number y2  Y coordinate of the segment's end.
    -- @param number z2  Z coordinate of the segment's end.
    -- @param[opt] function filter  When provided, it is used to "filter out" which items are returned.
    -- If `filter(item)` returns `false` or `nil`, that item is ignored. By default, all items are included.
    -- @return {table,...}  List of tables. Each element in the table has the following elements:
    -- `item`, `x1`, `y1`, `z1`, `x2`, `y2`, `z2`, `t0` and `t1`.
    -- @return number  Equivalent to `#itemInfo`.
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

    --- Extends the default list of available `filter()` function responses.
    -- Further explanation would be written in near future.
    -- @param string name  Response name to be used as `filter`'s return value.
    -- @param function response  Callback function calculating resulting movement position for that specific response.
    function World:addResponse(name, response)
        -- TODO: add support for callable tables
        self.responses[name] = assert(type(response) == 'function' and response, 'World\'s response must be a function')
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