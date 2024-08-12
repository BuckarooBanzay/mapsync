
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
    
    -- data file
    assert(mapsync.get_data_file("myfile.txt")) -- defaults to read-mode
    assert(mapsync.get_data_file("myfile2.txt", "w"))
    assert(not mapsync.get_data_file("myfile-non-existent-file.txt", "r"))

    -- write to data file
    assert(not mapsync.get_data_file("myfile3.txt"))
    local f = mapsync.get_data_file("myfile3.txt", "w")
    assert(f)
    f:write("stuff")
    f:close()
    assert(mapsync.get_data_file("myfile3.txt"))

    callback()
end)