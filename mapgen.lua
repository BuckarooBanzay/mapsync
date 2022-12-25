minetest.register_on_generated(function(minp)
    local chunk_pos = mapsync.get_chunkpos(minp)
    local backend = mapsync.select_backend(chunk_pos)
    if not backend then
        return
    end

    backend.load_chunk(chunk_pos)
end)