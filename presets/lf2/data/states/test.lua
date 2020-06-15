return function ( entity, data )
    entity.vars.test = entity.vars.test or {
        speed = 0
    }

    entity.vars.test.speed = entity.vars.test.speed + data.speed
    entity.vars.x = entity.vars.x + entity.vars.test.speed
end
