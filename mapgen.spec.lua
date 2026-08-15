local BACKEND_NAME = "test-mapgen-backend"

mtt.register("mapgen-test (register)", function(callback)
    -- backend for mapgen test
    mapsync.register_backend(BACKEND_NAME, {
        type = "fs",
        path = minetest.get_modpath("mapsync") .. "/test/map"
    })
    callback()
end)

local pos = { x=0, y=0, z=0 }
mtt.emerge_area(pos, pos)

mtt.register("mapgen-test (unregister)", function(callback)
    mapsync.unregister_backend(BACKEND_NAME)
    callback()
end)