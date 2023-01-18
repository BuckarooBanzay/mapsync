


function mapsync.deserialize_mapblock(mapblock_pos, blockdata, node_data, param1, param2, area)
    local pos1 = vector.multiply(mapblock_pos, 16)
	local pos2 = vector.add(pos1, 15) -- inclusive

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