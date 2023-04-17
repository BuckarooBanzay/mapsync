
mtt.emerge_area({x=0, y=0, z=0}, {x=32, y=32, z=32})

mtt.register("validate", function(callback)
    local path = minetest.get_worldpath() .. "/mymap"
    minetest.mkdir(path)
    mapsync.register_backend("my-backend", {
        type = "fs",
        path = path
    })

    local pos = {x=0, y=0, z=0}
    assert(mapsync.save(pos))

    local backend_def = mapsync.select_backend(pos)
    assert(backend_def)

    local handler = mapsync.select_handler(backend_def)
    assert(handler)

    local manifest, m_err = handler.get_manifest(backend_def, pos)
    assert(not m_err)
    assert(manifest)

    local success, err = mapsync.validate("my-backend")
    assert(success)
    assert(not err)

    callback()
end)