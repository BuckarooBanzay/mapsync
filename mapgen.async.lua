minetest.register_on_generated(function(vmanip, minp)
    local chunk_pos = mapsync.get_chunkpos(minp)

    local t1 = minetest.get_us_time()
    mapsync.load(chunk_pos, vmanip)
    local t2 = minetest.get_us_time()

    local micros = t2 - t1
    if micros > 0 then
        -- log slow chunks
        minetest.log(
            "action",
            "[mapsync] async emerge of " .. minetest.pos_to_string(chunk_pos) .. " took " .. micros .. " us"
        )
    end
end)
