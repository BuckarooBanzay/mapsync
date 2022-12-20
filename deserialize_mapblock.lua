
function mapsync.deserialize_mapblock(mapblock_pos, blockdata)
    local pos1 = vector.multiply(mapblock_pos, 16)
	local pos2 = vector.add(pos1, 15) -- inclusive

	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(pos1, pos2)
	local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})

	local node_data = manip:get_data()
	local param1 = manip:get_light_data()
	local param2 = manip:get_param2_data()

	local j = 1
	for z=pos1.z,pos2.z do
	for x=pos1.x,pos2.x do
	for y=pos1.y,pos2.y do
		local i = area:index(x,y,z)
		node_data[i] = blockdata.node_ids[j]
		param1[i] = blockdata.param1[j]
		param2[i] = blockdata.param2[j]
		j = j + 1
	end
	end
	end

	manip:set_data(node_data)
	manip:set_light_data(param1)
	manip:set_param2_data(param2)
	manip:write_to_map(false)

	-- deserialize metadata
	if blockdata.metadata and blockdata.metadata.meta then
		for pos_str, md in pairs(blockdata.metadata.meta) do
			local relative_pos = minetest.string_to_pos(pos_str)
			local absolute_pos = vector.add(pos1, relative_pos)
			minetest.get_meta(absolute_pos):from_table(md)
		end
	end

	-- deserialize node timers
	if blockdata.metadata and blockdata.metadata.timers then
		for pos_str, timer_data in pairs(blockdata.metadata.timers) do
			local relative_pos = minetest.string_to_pos(pos_str)
			local absolute_pos = vector.add(pos1, relative_pos)
			minetest.get_node_timer(absolute_pos):set(timer_data.timeout, timer_data.elapsed)
		end
	end

    return true
end