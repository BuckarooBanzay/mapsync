local global_env = ...

-- local vars for faster access
local insert, byte, decode_uint16 = table.insert, string.byte, mapsync.decode_uint16

-- parses an exported chunk file
function mapsync.parse_chunk(filename)
    local f = global_env.io.open(filename, "rb")
    local zip, err_msg = mtzip.unzip(f)
    if not zip then
        return false, err_msg
    end

    -- parse manifest
    local manifest_str, m_err_msg = zip:get("manifest.json")
    if not manifest_str then
        return false, m_err_msg
    end
    local manifest = minetest.parse_json(manifest_str)

    -- parse metadata
    local metadata_str, md_err_msg = zip:get("metadata.json")
    if not metadata_str then
        return false, md_err_msg
    end
    local metadata = minetest.parse_json(metadata_str) or {}

    -- parse mapdata
    local mapdata, map_err_msg = zip:get("mapdata.bin")
    if not mapdata then
        return false, map_err_msg
    end

    local mapblock_count = #manifest.block_pos

    local chunk = {
        manifest = manifest,
        mapblocks = {}
    }

    local param1_offset = 4096 * 2 * mapblock_count
    local param2_offset = 4096 * 3 * mapblock_count

    for mbi, rel_mapblock_pos in ipairs(manifest.block_pos) do
        local blockdata = {
            node_ids = {},
            param1 = {},
            param2 = {},
            metadata = metadata[minetest.pos_to_string(rel_mapblock_pos)]
        }

        for i=1,4096 do
            local node_id = decode_uint16(mapdata, ((mbi-1) * 4096 * 2) + (i * 2) - 2)
            local param1 = byte(mapdata, param1_offset + ((mbi-1) * 4096) + i)
            local param2 = byte(mapdata, param2_offset + ((mbi-1) * 4096) + i)

            insert(blockdata.node_ids, node_id)
            insert(blockdata.param1, param1)
            insert(blockdata.param2, param2)
        end

        mapsync.localize_nodeids(manifest.node_mapping, blockdata.node_ids)

        chunk.mapblocks[minetest.pos_to_string(rel_mapblock_pos)] = blockdata
    end

    return chunk
end