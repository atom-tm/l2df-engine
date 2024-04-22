--[[

    State is a function which is called on every game update (tick) if it is active.

    States added to `data.states` are called once on the next update and data.states is cleared.
    To call state again it should be added again to data.states.
    It's can be done automatically using <state> tag from object's <frame> data.

    States added to `data.constates` are called on every update until data.constates is cleared manually.
    It can be used to implement passive abilities and effects.
    You can add such state using <constate> tag in object's data file.

    <constate> state_name </constate> # Adds constate named 'state_name' to object.
    <state> state_name argument2 argument3
        var: true  var2: 42  var3: "string"
    </state> # Adds state named 'state_name' with additional parameters which will be cleared after call.

    You also can add states using Lua instead of data files:

    -- Without parameters
    data.constates = { { state_name } }
    data.states = {
        -- Without parameters
        { state_name },
        -- With additional parameters
        { state_name, var = true, var2 = 42, var3 = "string" }
    }

    state_name - can be a number (legacy way) or a string (modern way).
    Function accepts 3 arguments:
        - object on which the state was added and called;
        - object's synchronized data. It equals to `object.data`;
        - variables / parameters passed to the state (as in the example above).

]]
return function (obj, data, params) -- state file should always return a defined function
    -- processing logic can be placed here
    -- e.g. you can work with components from `obj.C` to update object's `data`:
    -- if obj.C.controller.pressed('left') then
    --     data.dvx = 2
    --     data.facing = -1
    -- elseif obj.C.controller.pressed('right') then
    --     data.dvx = 2
    --     data.facing = 1
    -- end
end