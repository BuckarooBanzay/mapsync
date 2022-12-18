
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