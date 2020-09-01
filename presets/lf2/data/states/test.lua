return function (obj, data, params)
    data.test = data.test or { speed = 0 }

    data.test.speed = data.test.speed + params.speed
    data.x = data.x + data.test.speed
end
