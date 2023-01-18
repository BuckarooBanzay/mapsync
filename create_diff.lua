
function mapsync.create_diff(baseline_chunk, chunk_pos)
    local diff = {}
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
                end

                print(dump({
                    rel_mapblock_pos = rel_mapblock_pos
                }))
            end
        end
    end

    return diff
end
