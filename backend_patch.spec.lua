
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

    -- unregister fs backend
    mapsync.unregister_backend("my-backend")

    local patch_path = minetest.get_worldpath() .. "/patched"
    minetest.mkdir(patch_path)

    mapsync.register_backend("my-patched-backend", {
        type = "patch",
        shadow_path = path,
        path = patch_path
    })

    minetest.set_node({ x=10, y=10, z=10 }, { name = "default:obsidianbrick" })

    -- write patch
    success = mapsync.save(chunk_pos)
    assert(success)

    -- get patch handler
    local patch_backend_def = mapsync.get_backend("my-patched-backend")
    local patch_handler = mapsync.select_handler(patch_backend_def)

    -- apply patches back to shadowed backend
    patch_handler.apply_patches(patch_backend_def, function(chunk_count)
        assert(chunk_count == 1)
        -- cleanup
        mapsync.unregister_backend("my-patched-backend")
        callback()
    end)
end)