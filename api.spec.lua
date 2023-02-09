
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

    local backend = mapsync.select_backend({x=0, y=0, z=0})
    assert(backend.name == "my-backend")
    assert(backend.save_chunk({x=0, y=0, z=0}))

    local chunks = backend.list_chunks()
    assert(#chunks >= 1)
    assert(vector.equals(chunks[1], {x=0,y=0,z=0}))

    backend = mapsync.select_backend({x=0, y=10, z=0})
    assert(not backend)

    mapsync.unregister_backend("my-backend")
    callback()
end)