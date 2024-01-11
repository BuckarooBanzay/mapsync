
mtt.register("backend selection", function(callback)
    local path = minetest.get_worldpath() .. "/mymap"
    minetest.mkdir(path)
    mapsync.register_backend("my-backend", {
        type = "fs",
        path = path,
        select = function(chunk_pos)
            return chunk_pos.y < 10 and chunk_pos.y > -10
        end
    })

    local backend_def = mapsync.select_backend({x=0, y=0, z=0})
    assert(backend_def.name == "my-backend")

    assert(mapsync.save({x=0, y=0, z=0}))

    backend_def = mapsync.select_backend({x=0, y=10, z=0})
    assert(not backend_def)

    mapsync.unregister_backend("my-backend")
    callback()
end)