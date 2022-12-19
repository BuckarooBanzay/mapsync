
mtt.register("register and export", function(callback)
    local pos1 = { x=0, y=0, z=0 }
    local pos2 = { x=20, y=20, z=20 }

    mapsync.register_backend("worldpath", {
        path = minetest.get_worldpath() .. "/mymap",
        select = function()
            return true
        end
    })

    minetest.emerge_area(pos1, pos2, function(_, _, calls_remaining)
        if calls_remaining == 0 then
            callback()
        end
    end)
end)


mtt.register("serialize_chunk", function(callback)
    local pos1 = { x=0, y=0, z=0 }
    local pos2 = { x=20, y=20, z=20 }

    minetest.emerge_area(pos1, pos2, function(_, _, calls_remaining)
        if calls_remaining == 0 then
            local success, err_msg = mapsync.serialize_chunk({x=0, y=0, z=0}, minetest.get_worldpath() .. "/chunk.zip")
            assert(success)
            assert(not err_msg)
            callback()
        end
    end)
end)