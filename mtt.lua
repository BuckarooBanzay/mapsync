
mtt.register("register and export", function(callback)
    local pos1 = { x=0, y=0, z=0 }
    local pos2 = { x=20, y=20, z=20 }

    mapsync.register({
        path = minetest.get_worldpath() .. "/mymap"
    })

    minetest.emerge_area(pos1, pos2, function(_, _, calls_remaining)
        if calls_remaining == 0 then
            callback()
        end
    end)
end)