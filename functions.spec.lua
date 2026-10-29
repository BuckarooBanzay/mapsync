
mtt.register("mapblock_index_to_pos", function(callback)

    assert(vector.equals({x=0, y=0, z=0}, mapsync.mapblock_index_to_pos(0+1)))
    assert(vector.equals({x=0, y=10, z=0}, mapsync.mapblock_index_to_pos(10+1)))
    assert(vector.equals({x=1, y=0, z=0}, mapsync.mapblock_index_to_pos(16+1)))
    assert(vector.equals({x=10, y=0, z=0}, mapsync.mapblock_index_to_pos(160+1)))
    assert(vector.equals({x=1, y=1, z=0}, mapsync.mapblock_index_to_pos(17+1)))
    assert(vector.equals({x=0, y=0, z=1}, mapsync.mapblock_index_to_pos(256+1)))
    assert(vector.equals({x=0, y=1, z=1}, mapsync.mapblock_index_to_pos(256+1+1)))
    assert(vector.equals({x=1, y=1, z=1}, mapsync.mapblock_index_to_pos(256+1+16+1)))
    assert(vector.equals({x=0, y=0, z=2}, mapsync.mapblock_index_to_pos(512+1)))
    assert(vector.equals({x=15, y=15, z=15}, mapsync.mapblock_index_to_pos(4096)))

    callback()
end)

mtt.register("mapsync.deep_compare", function(callback)
    assert(mapsync.deep_compare(1,1))
    assert(not mapsync.deep_compare(2,1))

    assert(mapsync.deep_compare(nil, nil))
    assert(not mapsync.deep_compare(nil, {}))

    assert(mapsync.deep_compare({
        x = 1
    }, {
        x = 1
    }))
    assert(not mapsync.deep_compare({
        x = 1
    }, {
        x = 1,
        y = 2
    }))

    assert(mapsync.deep_compare({
        meta = {
            fields = {
                highscore_name = "s03"
            },
            inventory = nil
        },
        x = 34,
        y = 36,
        z = 72
    }, {
        meta = {
            fields = {
                highscore_name = "s03"
            },
            inventory = nil
        },
        x = 34,
        y = 36,
        z = 72
    }))

    -- missing key in the first table
    assert(not mapsync.deep_compare({ x = 1, y = 2 }, { x = 1 }))
    assert(mapsync.deep_compare({}, {}))

    -- type mismatches
    assert(not mapsync.deep_compare(1, "1"))
    assert(not mapsync.deep_compare({}, 1))
    assert(not mapsync.deep_compare(1, {}))

    -- nested difference
    assert(not mapsync.deep_compare({
        a = { b = { c = 1 } }
    }, {
        a = { b = { c = 2 } }
    }))

    callback()
end)


mtt.register("mapsync.get_mapblock", function(callback)
    assert(vector.equals({x=0, y=0, z=0}, mapsync.get_mapblock({x=0, y=0, z=0})))
    assert(vector.equals({x=0, y=0, z=0}, mapsync.get_mapblock({x=15, y=15, z=15})))
    assert(vector.equals({x=1, y=0, z=0}, mapsync.get_mapblock({x=16, y=0, z=0})))
    assert(vector.equals({x=-1, y=-1, z=-1}, mapsync.get_mapblock({x=-1, y=-1, z=-1})))
    assert(vector.equals({x=-1, y=-1, z=-1}, mapsync.get_mapblock({x=-16, y=-16, z=-16})))
    assert(vector.equals({x=-2, y=0, z=1}, mapsync.get_mapblock({x=-17, y=0, z=16})))

    callback()
end)

mtt.register("mapsync.get_chunkpos", function(callback)
    -- chunk 0 spans mapblocks -2..2
    assert(vector.equals({x=0, y=0, z=0}, mapsync.get_chunkpos({x=0, y=0, z=0})))
    assert(vector.equals({x=0, y=0, z=0}, mapsync.get_chunkpos({x=-32, y=-32, z=-32})))
    assert(vector.equals({x=0, y=0, z=0}, mapsync.get_chunkpos({x=47, y=47, z=47})))

    -- chunk boundaries
    assert(vector.equals({x=1, y=0, z=0}, mapsync.get_chunkpos({x=48, y=0, z=0})))
    assert(vector.equals({x=-1, y=0, z=0}, mapsync.get_chunkpos({x=-33, y=0, z=0})))
    assert(vector.equals({x=1, y=1, z=1}, mapsync.get_chunkpos({x=48, y=48, z=48})))
    assert(vector.equals({x=-1, y=-1, z=-1}, mapsync.get_chunkpos({x=-33, y=-33, z=-33})))

    callback()
end)

mtt.register("mapsync.get_mapblock_bounds_from_chunk", function(callback)
    local min, max = mapsync.get_mapblock_bounds_from_chunk({x=0, y=0, z=0})
    assert(vector.equals({x=-2, y=-2, z=-2}, min))
    assert(vector.equals({x=2, y=2, z=2}, max))

    min, max = mapsync.get_mapblock_bounds_from_chunk({x=1, y=0, z=-1})
    assert(vector.equals({x=3, y=-2, z=-7}, min))
    assert(vector.equals({x=7, y=2, z=-3}, max))

    -- a position is always inside the bounds of its own chunk
    for _, pos in ipairs({
        {x=0, y=0, z=0}, {x=-1, y=-1, z=-1}, {x=47, y=48, z=-33},
        {x=-500, y=300, z=1234}, {x=79, y=-80, z=80}
    }) do
        local chunk_pos = mapsync.get_chunkpos(pos)
        local mb_min, mb_max = mapsync.get_mapblock_bounds_from_chunk(chunk_pos)
        local mb = mapsync.get_mapblock(pos)
        assert(mb.x >= mb_min.x and mb.x <= mb_max.x)
        assert(mb.y >= mb_min.y and mb.y <= mb_max.y)
        assert(mb.z >= mb_min.z and mb.z <= mb_max.z)
    end

    callback()
end)

mtt.register("mapsync.get_node_bounds_from_mapblock", function(callback)
    local min, max = mapsync.get_node_bounds_from_mapblock({x=0, y=0, z=0})
    assert(vector.equals({x=0, y=0, z=0}, min))
    assert(vector.equals({x=15, y=15, z=15}, max))

    min, max = mapsync.get_node_bounds_from_mapblock({x=-1, y=2, z=1})
    assert(vector.equals({x=-16, y=32, z=16}, min))
    assert(vector.equals({x=-1, y=47, z=31}, max))

    callback()
end)

mtt.register("mapsync.sort_pos", function(callback)
    -- already sorted
    local min, max = mapsync.sort_pos({x=0, y=0, z=0}, {x=1, y=2, z=3})
    assert(vector.equals({x=0, y=0, z=0}, min))
    assert(vector.equals({x=1, y=2, z=3}, max))

    -- fully reversed
    min, max = mapsync.sort_pos({x=1, y=2, z=3}, {x=0, y=0, z=0})
    assert(vector.equals({x=0, y=0, z=0}, min))
    assert(vector.equals({x=1, y=2, z=3}, max))

    -- mixed axes
    min, max = mapsync.sort_pos({x=5, y=-1, z=7}, {x=2, y=4, z=-7})
    assert(vector.equals({x=2, y=-1, z=-7}, min))
    assert(vector.equals({x=5, y=4, z=7}, max))

    -- inputs are not mutated
    local p1, p2 = {x=5, y=5, z=5}, {x=0, y=0, z=0}
    mapsync.sort_pos(p1, p2)
    assert(vector.equals({x=5, y=5, z=5}, p1))
    assert(vector.equals({x=0, y=0, z=0}, p2))

    callback()
end)

mtt.register("mapsync chunk paths", function(callback)
    local pos = {x=1, y=-2, z=3}
    assert(mapsync.get_chunk_zip_path("/foo", pos) == "/foo/chunk_(1,-2,3).zip")
    assert(mapsync.get_chunk_json_path("/foo", pos) == "/foo/chunk_(1,-2,3).json")

    callback()
end)
