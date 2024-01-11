
function mapsync.load(chunk_pos, vmanip)
    local backend_def = mapsync.select_backend(chunk_pos)
    if not backend_def then
        return true, "No backend available"
    end

    -- load baseline chunk (might be non-existent)
    mapsync.deserialize_chunk(chunk_pos, mapsync.get_chunk_zip_path(backend_def.path, chunk_pos), vmanip)

    if backend_def.patch_path then
        -- load diff
        local f = io.open(mapsync.get_chunk_json_path(backend_def.patch_path, chunk_pos), "r")
        if not f then
            -- no diff
            return true
        end

        local changed_nodes = {}
        for line in f:lines() do
            local changed_node = minetest.parse_json(line)
            if changed_node then
                table.insert(changed_nodes, changed_node)
            end
        end
        f:close()

        -- apply diff
        local success, msg = mapsync.apply_diff(chunk_pos, changed_nodes)
        if not success then
            return false, msg
        end

        -- fix lighting
        local mb_pos1, mb_pos2 = mapsync.get_mapblock_bounds_from_chunk(chunk_pos)
        local pos1 = mapsync.get_node_bounds_from_mapblock(mb_pos1)
        local _, pos2 = mapsync.get_node_bounds_from_mapblock(mb_pos2)
        minetest.fix_light(pos1, pos2)
    end
end