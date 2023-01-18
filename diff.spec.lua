local pos = { x=0, y=0, z=0 }
mtt.emerge_area(pos, pos)

mtt.register("diff", function(callback)

    local chunk_pos = { x=0, y=0, z=0 }
    local filename = minetest.get_worldpath() .. "/mychunk.zip"

    -- serialize existing chunk
    assert(mapsync.serialize_chunk(chunk_pos, filename))
    local baseline_chunk, err_msg = mapsync.parse_chunk(filename)
    assert(baseline_chunk)
    assert(not err_msg)

    local diff = mapsync.create_diff(baseline_chunk, chunk_pos)
    assert(diff)

    callback()
end)