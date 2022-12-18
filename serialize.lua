local global_env = ...

function mapsync.serialize_chunk(chunk_pos, filename)
    local f = global_env.io.open(filename, "w")
    local zip = mtzip.zip(f)

    local min, max = mapsync.get_mapblock_bounds_from_chunk(chunk_pos)
    for x=min.x,max.x do
        for y=min.y,max.y do
            for z=min.z,max.z do
                local mapblock_pos = {x=x, y=y, z=z}
                local mapblock_data = mapsync.serialize_mapblock(mapblock_pos)
                if not mapblock_data.empty then
                    local prefix = "mapblock_" .. minetest.pos_to_string(mapblock_pos)
                    zip:add(prefix .. "_node_mapping.json", minetest.write_json(mapblock_data.node_mapping))
                    zip:add(prefix .. "_mapdata.bin", mapblock_data.mapdata)
                    if mapblock_data.has_metadata then
                        zip:add(prefix .. "_metadata.json", minetest.write_json(mapblock_data.metadata))
                    end
                end
            end
        end
    end

    zip:close()
    f:close()

    return true
end
