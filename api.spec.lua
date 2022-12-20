mtt.register("backend selection", function(callback)
    mapsync.register_backend("my-backend", {
        path = minetest.get_worldpath() .. "/mymap",
        select = function(chunk_pos)
            return chunk_pos.y < 10 and chunk_pos.y > -10
        end
    })

    local backend = mapsync.select_backend({x=0, y=0, z=0})
    assert(backend.name == "my-backend")

    backend = mapsync.select_backend({x=0, y=10, z=0})
    assert(not backend)

    callback()
end)