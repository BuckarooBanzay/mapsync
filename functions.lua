
-- returns a list of backends available for that position
function mapsync.select_backends(mapblock_pos)
    local backends = {}
    for _, backend_def in pairs(mapsync.get_backends()) do
        if backend_def.select(mapblock_pos) then
            table.insert(backends, backend_def)
        end
    end
    return backends
end

function mapsync.sort_pos(pos1, pos2)
	pos1 = {x=pos1.x, y=pos1.y, z=pos1.z}
	pos2 = {x=pos2.x, y=pos2.y, z=pos2.z}
	if pos1.x > pos2.x then
		pos2.x, pos1.x = pos1.x, pos2.x
	end
	if pos1.y > pos2.y then
		pos2.y, pos1.y = pos1.y, pos2.y
	end
	if pos1.z > pos2.z then
		pos2.z, pos1.z = pos1.z, pos2.z
	end
	return pos1, pos2
end

--- calculates the mapblock position from a node position
-- @param pos the node-position
-- @return the mapblock position
function mapsync.get_mapblock(pos)
	return vector.floor( vector.divide(pos, 16) )
end

--- returns the chunk position from a node position
-- @param pos the node-position
-- @return the chunk position
function mapsync.get_chunkpos(pos)
	local mapblock_pos = mapsync.get_mapblock(pos)
	local aligned_mapblock_pos = vector.add(mapblock_pos, 2)
	return vector.floor( vector.divide(aligned_mapblock_pos, 5) )
end

function mapsync.get_mapblock_bounds_from_chunk(chunk_pos)
	local min = vector.subtract( vector.multiply(chunk_pos, 5), 2)
	local max = vector.add(min, 4)
	return min, max
end

function mapsync.get_mapblock_bounds_from_mapblock(mapblock)
	local min = vector.multiply(mapblock, 16)
	local max = vector.add(min, 15)
	return min, max
end

-- returns the mtime of the emerged chunk (mtime from manifest)
function mapsync.get_world_chunk_mtime(chunk_pos)
	local mtime = mapsync.storage:get_int(minetest.pos_to_string(chunk_pos))
    if mtime == 0 then
        return nil
    else
        return mtime
    end
end

-- returns the mtime of the backend chunk
function mapsync.get_backend_chunk_mtime(chunk_pos)
	local backend_def = mapsync.select_backend(chunk_pos)
    if not backend_def then
        return
    end

	local handler = mapsync.select_handler(backend_def)

    -- get manifest
    local manifest = handler.get_manifest(backend_def, chunk_pos)
    if not manifest then
        return
    end

    -- retrieve timestamps
    return manifest.mtime
end

-- deletes a chunk from the ingame map
function mapsync.delete_chunk(chunk_pos)
	local mapblock_min, mapblock_max = mapsync.get_mapblock_bounds_from_chunk(chunk_pos)
    local min = mapsync.get_mapblock_bounds_from_mapblock(mapblock_min)
    local _, max = mapsync.get_mapblock_bounds_from_mapblock(mapblock_max)

	mapsync.storage:set_string(minetest.pos_to_string(chunk_pos), "")
    minetest.delete_area(min, max)
end

-- emerges a chunk
function mapsync.emerge_chunk(chunk_pos, callback)
	local mapblock_min, mapblock_max = mapsync.get_mapblock_bounds_from_chunk(chunk_pos)
	local min = mapsync.get_mapblock_bounds_from_mapblock(mapblock_min)
	local _, max = mapsync.get_mapblock_bounds_from_mapblock(mapblock_max)

	minetest.emerge_area(min, max, function(_, _, calls_remaining)
		if calls_remaining == 0 and type(callback) == "function" then
			callback()
		end
	end)
end

function mapsync.mapblock_index_to_pos(index)
    index = index - 1
    local y = index % 16
    index = index - y
	local z = math.floor(index / 256)
	index = index - (z * 256)
	local x = math.floor(index / 16)

	return { x=x, y=y, z=z }
end

-- Source: https://gist.github.com/sapphyrus/fd9aeb871e3ce966cc4b0b969f62f539, license: MIT
function mapsync.deep_compare(tbl1, tbl2)
	if tbl1 == tbl2 then
		return true
	elseif type(tbl1) == "table" and type(tbl2) == "table" then
		for key1, value1 in pairs(tbl1) do
			local value2 = tbl2[key1]

			if value2 == nil then
				-- avoid the type call for missing keys in tbl2 by directly comparing with nil
				return false
			elseif value1 ~= value2 then
				if type(value1) == "table" and type(value2) == "table" then
					if not mapsync.deep_compare(value1, value2) then
						return false
					end
				else
					return false
				end
			end
		end

		-- check for missing keys in tbl1
		for key2, _ in pairs(tbl2) do
			if tbl1[key2] == nil then
				return false
			end
		end

		return true
	end

	return false
end