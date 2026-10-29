mtt.register("localize_nodeids", function(callback)
    local air_id = minetest.get_content_id("air")
    local stone_id = minetest.get_content_id("default:stone")
    local mese_id = minetest.get_content_id("default:mese")

    -- known nodes are mapped to the local ids, foreign ids are replaced
    local mapping = { ["air"] = 5, ["default:stone"] = 100 }
    local ids = { 100, 5, 100, 5 }
    mapsync.localize_nodeids(mapping, ids)
    assert(ids[1] == stone_id)
    assert(ids[2] == air_id)
    assert(ids[3] == stone_id)
    assert(ids[4] == air_id)

    -- unavailable nodes are replaced with air
    mapping = { ["default:stone"] = 1, ["mapsync:does_not_exist"] = 2 }
    ids = { 1, 2, 1 }
    mapsync.localize_nodeids(mapping, ids)
    assert(ids[1] == stone_id)
    assert(ids[2] == air_id)
    assert(ids[3] == stone_id)

    -- a different mapping with reused foreign ids must not be affected by a previous call
    mapping = { ["default:mese"] = 1, ["default:stone"] = 2 }
    ids = { 1, 2 }
    mapsync.localize_nodeids(mapping, ids)
    assert(ids[1] == mese_id)
    assert(ids[2] == stone_id)

    -- empty list
    ids = {}
    mapsync.localize_nodeids(mapping, ids)
    assert(#ids == 0)

    callback()
end)
