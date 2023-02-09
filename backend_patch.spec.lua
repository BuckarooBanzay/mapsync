
mtt.register("patch backend", function(callback)
    local chunk_pos = { x=0, y=0, z=0 }

    local path = minetest.get_worldpath() .. "/unpatched"
    minetest.mkdir(path)

    mapsync.register_backend("my-backend", {
        type = "fs",
        path = path
    })

    -- write chunk
    local success = mapsync.save(chunk_pos)
    assert(success)

    local patch_path = minetest.get_worldpath() .. "/patched"
    minetest.mkdir(patch_path)

    mapsync.register_backend("my-patched-backend", {
        type = "patch",
        shadow = "my-backend",
        path = patch_path
    })

    minetest.set_node({ x=10, y=10, z=10 }, { name = "default:mese" })

    -- write patch
    success = mapsync.save(chunk_pos)
    assert(success)

    mapsync.unregister_backend("my-patched-backend")
    callback()
end)