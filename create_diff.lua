local c_air = minetest.get_content_id("air")

local function create_mapblock(mapblock_pos, mapblock, callback)
    assert(#mapblock.node_ids == 4096)
    assert(#mapblock.param1 == 4096)
    assert(#mapblock.param2 == 4096)

    for i=1,4096 do
        -- relative position in the mapblock
        local rel_pos = mapsync.mapblock_index_to_pos(i)

        -- relative position in the chunk
        local rel_chunk_pos = vector.add(rel_pos, vector.multiply(mapblock_pos, 16))

        local nodeid = mapblock.node_ids[i]
        if nodeid ~= c_air then
            local nodename = minetest.get_name_from_content_id(nodeid)

            local node = {
                x=rel_chunk_pos.x,
                y=rel_chunk_pos.y,
                z=rel_chunk_pos.z,
                name = nodename,
                param2 = mapblock.param2[i],
                param1 = mapblock.param1[i]
            }

            if mapblock.metadata then
                local rel_pos_str = minetest.pos_to_string(rel_pos)
                if mapblock.metadata.meta then
                    node.meta = mapblock.metadata.meta[rel_pos_str]
                end
                if mapblock.metadata.meta then
                    node.timer = mapblock.metadata.timers[rel_pos_str]
                end
            end

            callback(node)
        end
    end
end

local function air_mapblock(mapblock_pos, callback)
    for i=1,4096 do
        -- relative position in the mapblock
        local rel_pos = mapsync.mapblock_index_to_pos(i)
        -- relative position in the chunk
        local rel_chunk_pos = vector.add(rel_pos, vector.multiply(mapblock_pos, 16))

        local node = {
            x=rel_chunk_pos.x,
            y=rel_chunk_pos.y,
            z=rel_chunk_pos.z,
            name = "air",
            param2 = 0
        }

        callback(node)
    end
end

local function diff_mapblock(mapblock_pos, baseline_mapblock, mapblock, callback, opts)
    assert(#baseline_mapblock.node_ids == 4096)
    assert(#baseline_mapblock.param1 == 4096)
    assert(#baseline_mapblock.param2 == 4096)
    assert(#mapblock.node_ids == 4096)
    assert(#mapblock.param1 == 4096)
    assert(#mapblock.param2 == 4096)

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
        local param1_delta = math.abs(baseline_mapblock.param1[i] - mapblock.param1[i])
        if param1_delta > opts.param1_max_delta then
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

        local timer = mapblock.metadata and mapblock.metadata.timers and mapblock.metadata.timers[rel_pos_str]
        if timer then
            node.timer = timer
        end

        if changed then
            callback(node)
        end
    end

    return true
end

function mapsync.create_diff(baseline_chunk, chunk_pos, callback, opts)
    opts = opts or {}
    opts.param1_max_delta = opts.param1_max_delta or 0

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
                    air_mapblock(mapblock_pos, callback)

                elseif not blockdata.empty and not baseline_mapblock then
                    -- block added
                    create_mapblock(mapblock_pos, blockdata, callback)

                elseif not blockdata.empty and baseline_mapblock then
                    -- both blocks exist, compare
                    local success, err_msg = diff_mapblock(rel_mapblock_pos,baseline_mapblock,blockdata,callback,opts)
                    if not success then
                        return false, err_msg
                    end

                end
            end
        end
    end

    return true
end
