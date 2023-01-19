
mtt.register("mapblock_index_to_pos", function(callback)

    assert(vector.equals({x=0, y=0, z=0}, mapsync.mapblock_index_to_pos(0+1)))
    assert(vector.equals({x=0, y=10, z=0}, mapsync.mapblock_index_to_pos(10+1)))
    assert(vector.equals({x=1, y=0, z=0}, mapsync.mapblock_index_to_pos(16+1)))
    assert(vector.equals({x=10, y=0, z=0}, mapsync.mapblock_index_to_pos(160+1)))
    assert(vector.equals({x=1, y=1, z=0}, mapsync.mapblock_index_to_pos(17+1)))
    assert(vector.equals({x=0, y=0, z=1}, mapsync.mapblock_index_to_pos(256+1)))
    assert(vector.equals({x=0, y=1, z=1}, mapsync.mapblock_index_to_pos(256+1+1)))
    assert(vector.equals({x=1, y=1, z=1}, mapsync.mapblock_index_to_pos(256+1+16+1)))
    assert(vector.equals({x=0, y=0, z=2}, mapsync.mapblock_index_to_pos(512+1)))
    assert(vector.equals({x=15, y=15, z=15}, mapsync.mapblock_index_to_pos(4096)))

    callback()
end)