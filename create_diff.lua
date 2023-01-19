local global_env = ...

local function diff_mapblock(mapblock_pos, baseline_mapblock, mapblock, f)
    assert(#baseline_mapblock.node_ids == 4096)
    assert(#baseline_mapblock.param1 == 4096)
    assert(#baseline_mapblock.param2 == 4096)
    assert(#mapblock.node_ids == 4096)
    assert(#mapblock.param1 == 4096)
    assert(#mapblock.param2 == 4096)

    print(dump(mapblock.metadata))

    for i=1,4096 do
        -- relative position in the mapblock
        local rel_pos = mapsync.mapblock_index_to_pos(i)
        -- relative position in the chunk
        local rel_chunk_pos = vector.add(rel_pos, vector.multiply(mapblock_pos, 16))

        local baseline_nodeid = baseline_mapblock.node_ids[i]
        local new_nodeid = mapblock.node_ids[i]
        local node = { x=rel_chunk_pos.x, y=rel_chunk_pos.y, z=rel_chunk_pos.z }
        local changed = false

        -- node id
        if baseline_nodeid ~= new_nodeid then
            local new_nodename = minetest.get_name_from_content_id(new_nodeid)
            node.name = new_nodename
            changed = true
        end

        -- param1
        if baseline_mapblock.param1[i] ~= mapblock.param1[i] then
            node.param1 = mapblock.param1[i]
            changed = true
        end

        -- param2
        if baseline_mapblock.param2[i] ~= mapblock.param2[i] then
            node.param2 = mapblock.param2[i]
            changed = true
        end

        -- metadata
        local rel_pos_str = minetest.pos_to_string(rel_pos)
        local baseline_meta = baseline_mapblock.metadata
            and baseline_mapblock.metadata.meta
            and baseline_mapblock.metadata.meta[rel_pos_str]
        local new_meta = mapblock.metadata and mapblock.metadata.meta and mapblock.metadata.meta[rel_pos_str]
        if new_meta and not mapsync.deep_compare(baseline_meta, new_meta) then
            -- metadata not equal or new
            node.meta = new_meta
            changed = true
        end

        -- TODO: node timers

        if changed then
            print(dump(node))
            f:write(minetest.write_json(node), "\n")
        end
    end

    return true
end

function mapsync.create_diff(baseline_chunk, chunk_pos, filename)
    local f = global_env.io.open(filename, "w")
    if not f then
        return false, "could not open '" .. filename .. "'"
    end

    local node_mapping = {}
    local mb_pos1, mb_pos2 = mapsync.get_mapblock_bounds_from_chunk(chunk_pos)

    for x=mb_pos1.x,mb_pos2.x do
        for y=mb_pos1.y,mb_pos2.y do
            for z=mb_pos1.z,mb_pos2.z do
                local mapblock_pos = {x=x, y=y, z=z}
                local rel_mapblock_pos = vector.subtract(mapblock_pos, mb_pos1)
                local blockdata = mapsync.serialize_mapblock(mapblock_pos, node_mapping)
                local baseline_mapblock = baseline_chunk.mapblocks[minetest.pos_to_string(rel_mapblock_pos)]

                if blockdata.empty and baseline_mapblock then
                    -- block removed
                elseif not blockdata.empty and not baseline_mapblock then
                    -- block added
                elseif blockdata.empty and not baseline_mapblock then
                    -- nothing here, nothing changed
                else
                    -- both blocks exist, compare
                    local success, err_msg = diff_mapblock(rel_mapblock_pos, baseline_mapblock, blockdata, f)
                    if not success then
                        return false, err_msg
                    end
                end
            end
        end
    end

    f:close()

    return true
end
