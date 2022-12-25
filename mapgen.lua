minetest.register_on_generated(function(minp)
    local chunk_pos = mapsync.get_chunkpos(minp)
    local backend = mapsync.select_backend(chunk_pos)
    if not backend then
        return
    end

    local vmanip = minetest.get_mapgen_object("voxelmanip")
    backend.load_chunk(chunk_pos, vmanip)
end)