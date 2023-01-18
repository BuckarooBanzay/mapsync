minetest.register_on_generated(function(minp)
    local chunk_pos = mapsync.get_chunkpos(minp)
    local backend = mapsync.select_backend(chunk_pos)
    if not backend then
        return
    end

    local t1 = minetest.get_us_time()
    local vmanip = minetest.get_mapgen_object("voxelmanip")
    backend.load_chunk(chunk_pos, vmanip)
    local t2 = minetest.get_us_time()
    local micros = t2 - t1
    if micros > 10000 then
        -- log slow chunks
        minetest.log(
            "action",
            "[mapsync] emerge of " .. minetest.pos_to_string(chunk_pos) .. " took " .. micros .. " us"
        )
    end
end)