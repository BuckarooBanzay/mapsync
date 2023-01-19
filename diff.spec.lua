local pos = { x=0, y=0, z=0 }
mtt.emerge_area(pos, pos)

mtt.register("diff", function(callback)

    local chunk_pos = { x=0, y=0, z=0 }
    local filename = minetest.get_worldpath() .. "/mychunk.zip"
    local diff_filename = minetest.get_worldpath() .. "/mydiff.json"

    -- serialize existing chunk
    assert(mapsync.serialize_chunk(chunk_pos, filename))
    local baseline_chunk, err_msg = mapsync.parse_chunk(filename)
    assert(baseline_chunk)
    assert(not err_msg)

    -- change things
    minetest.set_node({ x=10, y=0, z=0 }, { name = "default:mese" })

    minetest.set_node({ x=10, y=1, z=0 }, { name = "default:chest" })
    local meta = minetest.get_meta({ x=10, y=1, z=0 })
    meta:set_int("x", 10)

    -- create and validate diff
    local success = mapsync.create_diff(baseline_chunk, chunk_pos, diff_filename)
    assert(success)

    callback()
end)