
mtt.register("data", function(callback)
    local path = minetest.get_worldpath() .. "/data"
    minetest.mkdir(path)

    mapsync.register_data_backend({
        type = "fs",
        path = path
    })

    mapsync.save_data("x", { y = 1 })

    local value = mapsync.load_data("x")
    assert(value)
    assert(value.y == 1)

    assert(not mapsync.load_data("y"))

    callback()
end)