local global_env = ...

-- local vars for faster access
local char, encode_uint16, insert = string.char, mapsync.encode_uint16, table.insert

function mapsync.serialize_chunk(chunk_pos, filename)

    local chunk_empty = true
    local blockdata_list = {}
    local node_mapping = {}

    -- collect all non-empty block-datas
    local min, max = mapsync.get_mapblock_bounds_from_chunk(chunk_pos)
    for x=min.x,max.x do
        for y=min.y,max.y do
            for z=min.z,max.z do
                local mapblock_pos = {x=x, y=y, z=z}
                local blockdata = mapsync.serialize_mapblock(mapblock_pos, node_mapping)
                blockdata.rel_pos = vector.subtract(mapblock_pos, min)

                if not blockdata.empty then
                    chunk_empty = false
                    insert(blockdata_list, blockdata)
                end
            end
        end
    end

    if chunk_empty then
        -- skip empty chunks
        return true
    end

    local node_mapping_count = 0
    for _ in pairs(node_mapping) do
        node_mapping_count = node_mapping_count + 1
    end

    if node_mapping_count == 1 and node_mapping["air"] then
        -- only light changed and just air, skip
        return true
    end

    -- get key manifest from zip before overwriting
    local key_manifest = mapsync.parse_chunk_key(filename)

    -- open zip for writing
    local f = global_env.io.open(filename, "wb")
    if not f then
        return false, "could not open '" .. filename .. "'"
    end
    local zip = mtzip.zip(f)

    -- marshal blockdata to export-entries
    local mapdata = {}

    -- node_ids
    for _, blockdata in ipairs(blockdata_list) do
        for i=1,#blockdata.node_ids do
            insert(mapdata, encode_uint16(blockdata.node_ids[i]))
        end
    end

    -- param1
    for _, blockdata in ipairs(blockdata_list) do
        for i=1,#blockdata.param1 do
            insert(mapdata, char(blockdata.param1[i]))
        end
    end

    -- param2
    for _, blockdata in ipairs(blockdata_list) do
        for i=1,#blockdata.param2 do
            insert(mapdata, char(blockdata.param2[i]))
        end
    end

    -- metadata / manifest
    local manifest = {
        -- nodename => node_id
        node_mapping = node_mapping,
        -- seconds utc
        mtime = os.time(),
        -- { pos1, pos2, ... }
        block_pos = {},
        -- mapsync version
        mapsync_version = mapsync.version
    }
    local metadata = {}

    for _, blockdata in ipairs(blockdata_list) do
        insert(manifest.block_pos, blockdata.rel_pos)
        if blockdata.has_metadata then
            metadata[minetest.pos_to_string(blockdata.rel_pos)] = blockdata.metadata
        end
    end

    if key_manifest then
        -- encrypt and add key manifest
        -- TODO
    else
        -- store plain
        zip:add("mapdata.bin", table.concat(mapdata))
        zip:add("metadata.json", minetest.write_json(metadata))
        zip:add("manifest.json", minetest.write_json(manifest))
    end

    zip:close()
    f:close()

    return true
end
