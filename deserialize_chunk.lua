local global_env = ...

-- deserializes the chunk to the world
function mapsync.deserialize_chunk(chunk_pos, filename, vmanip)
    local chunk, err_msg = mapsync.parse_chunk(filename)
    if not chunk then
        return false, err_msg
    end

    local min_mapblock = mapsync.get_mapblock_bounds_from_chunk(chunk_pos)

    for rel_mapblock_pos_str, blockdata in pairs(chunk.mapblocks) do
        local rel_mapblock_pos = minetest.string_to_pos(rel_mapblock_pos_str)
        local mapblock_pos = vector.add(rel_mapblock_pos, min_mapblock)
        mapsync.deserialize_mapblock(mapblock_pos, blockdata, vmanip)
    end

    -- update or set the manifest mtime
    mapsync.storage:set_int(minetest.pos_to_string(chunk_pos), chunk.manifest.mtime)

    return true
end

-- returns the parsed manifest of the chunk
function mapsync.get_manifest(filename)
	local f = global_env.io.open(filename)
    local zip, err_msg = mtzip.unzip(f)
    if not zip then
        return nil, err_msg
    end

    -- parse manifest
    local manifest_str, m_err_msg = zip:get("manifest.json")
    if not manifest_str then
        return nil, m_err_msg
    end
    return minetest.parse_json(manifest_str)
end
