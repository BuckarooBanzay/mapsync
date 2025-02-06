
function mapsync.load(chunk_pos, vmanip)
    local backend_def = mapsync.select_backend(chunk_pos)
    if not backend_def then
        return true, "No backend available"
    end

    mapsync.deserialize_chunk(chunk_pos, mapsync.get_chunk_zip_path(backend_def.path, chunk_pos), vmanip)
end