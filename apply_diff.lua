
function mapsync.apply_diff(chunk_pos, changed_nodes)
    local min_mb, max_mb = mapsync.get_mapblock_bounds_from_chunk(chunk_pos)
    local base_pos = mapsync.get_node_bounds_from_mapblock(min_mb)
    local _, max_pos = mapsync.get_node_bounds_from_mapblock(max_mb)

    -- load chunk
    local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(base_pos, max_pos)
	local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})

	local node_data = manip:get_data()
	local param2 = manip:get_param2_data()

    for _, changed_node in ipairs(changed_nodes) do
        -- absolute node position
        local pos = {
            x = base_pos.x + changed_node.x,
            y = base_pos.y + changed_node.y,
            z = base_pos.z + changed_node.z
        }

        local index = area:index(pos.x, pos.y, pos.z)

        if changed_node.name ~= nil then
            if minetest.registered_nodes[changed_node.name] then
                local id = minetest.get_content_id(changed_node.name)
                node_data[index] = id
            end
            -- TODO: placeholder if not found
        end

        if changed_node.param2 ~= nil then
            param2[index] = changed_node.param2
        end

        if changed_node.timer ~= nil then
            local timer = minetest.get_node_timer(pos)
            timer:set(changed_node.timer.timeout, changed_node.timer.elapsed)
        end

        if changed_node.meta ~= nil then
            minetest.get_meta(pos):from_table(changed_node.meta)
        end
    end

    -- write back to map
    manip:set_data(node_data)
	manip:set_param2_data(param2)
    manip:write_to_map(true)

    return true
end
