-- nodes used in the tests
minetest.register_node("mapsync:test_ignored", {
    groups = { mapsync_ignore = 1 }
})

minetest.register_node("mapsync:test_meta", {})

minetest.register_node("mapsync:test_timer", {
    on_timer = function() return false end
})

-- emerge chunk (-1,-1,-1) for the negative-position test
local negative_pos = { x=-50, y=-50, z=-50 }
mtt.emerge_area(negative_pos, negative_pos)

-- serializes the source chunk, deserializes it into the target chunk
-- returns the node-offset between the chunks
local function copy_chunk(source_chunk_pos, target_chunk_pos, filename)
    local success, err_msg = mapsync.serialize_chunk(source_chunk_pos, filename)
    assert(success)
    assert(not err_msg)

    local vmanip = minetest.get_voxel_manip()
    local mb_pos1, mb_pos2 = mapsync.get_mapblock_bounds_from_chunk(target_chunk_pos)
    local pos1 = mapsync.get_node_bounds_from_mapblock(mb_pos1)
    local _, pos2 = mapsync.get_node_bounds_from_mapblock(mb_pos2)
    vmanip:read_from_map(pos1, pos2)

    success, err_msg = mapsync.deserialize_chunk(target_chunk_pos, filename, vmanip)
    assert(success)
    assert(not err_msg)

    return vector.multiply(vector.subtract(target_chunk_pos, source_chunk_pos), 80)
end

mtt.register("serialize_mapblock nodes and params", function(callback)
    local mapblock_pos = { x=0, y=0, z=0 }
    local node_pos = { x=3, y=4, z=5 }

    minetest.set_node(node_pos, { name = "default:mese", param2 = 66 })

    local node_mapping = {}
    local blockdata = mapsync.serialize_mapblock(mapblock_pos, node_mapping)

    assert(#blockdata.node_ids == 4096)
    assert(#blockdata.param1 == 4096)
    assert(#blockdata.param2 == 4096)
    assert(not blockdata.empty)

    -- iteration order is z, x, y
    local index = (5 * 256) + (3 * 16) + 4 + 1
    assert(node_mapping["default:mese"])
    assert(blockdata.node_ids[index] == node_mapping["default:mese"])
    assert(blockdata.param2[index] == 66)

    callback()
end)

mtt.register("serialize_mapblock ignored nodes", function(callback)
    local mapblock_pos = { x=0, y=0, z=0 }
    local node_pos = { x=6, y=7, z=8 }

    minetest.set_node(node_pos, { name = "mapsync:test_ignored" })

    local node_mapping = {}
    local blockdata = mapsync.serialize_mapblock(mapblock_pos, node_mapping)

    local index = (8 * 256) + (6 * 16) + 7 + 1
    assert(node_mapping["air"])
    assert(blockdata.node_ids[index] == node_mapping["air"])
    assert(not node_mapping["mapsync:test_ignored"])

    callback()
end)

mtt.register("serialize and deserialize chunk metadata", function(callback)
    local chunk_pos = { x=0, y=0, z=0 }
    local target_chunk_pos = { x=0, y=0, z=1 }
    local node_pos = { x=20, y=6, z=20 }

    minetest.set_node(node_pos, { name = "mapsync:test_meta" })
    local meta = minetest.get_meta(node_pos)
    meta:set_string("foo", "bar")
    local inv = meta:get_inventory()
    inv:set_size("main", 4)
    inv:set_stack("main", 2, ItemStack("default:steel_ingot 5"))

    local offset = copy_chunk(chunk_pos, target_chunk_pos, minetest.get_worldpath() .. "/chunk_meta.zip")
    local target_pos = vector.add(node_pos, offset)

    assert(minetest.get_node(target_pos).name == "mapsync:test_meta")
    local target_meta = minetest.get_meta(target_pos)
    assert(target_meta:get_string("foo") == "bar")

    local target_inv = target_meta:get_inventory()
    assert(target_inv:get_size("main") == 4)
    assert(target_inv:get_stack("main", 1):is_empty())
    assert(target_inv:get_stack("main", 2):to_string() == "default:steel_ingot 5")

    callback()
end)

mtt.register("serialize and deserialize chunk node-timers", function(callback)
    local chunk_pos = { x=0, y=0, z=0 }
    local target_chunk_pos = { x=0, y=0, z=1 }
    local started_pos = { x=30, y=6, z=20 }
    local stopped_pos = { x=31, y=6, z=20 }

    minetest.set_node(started_pos, { name = "mapsync:test_timer" })
    minetest.set_node(stopped_pos, { name = "mapsync:test_timer" })
    minetest.get_node_timer(started_pos):start(1000)
    minetest.get_node_timer(stopped_pos):stop()

    local offset = copy_chunk(chunk_pos, target_chunk_pos, minetest.get_worldpath() .. "/chunk_timer.zip")

    local started_timer = minetest.get_node_timer(vector.add(started_pos, offset))
    assert(started_timer:is_started())
    assert(started_timer:get_timeout() == 1000)

    local stopped_timer = minetest.get_node_timer(vector.add(stopped_pos, offset))
    assert(not stopped_timer:is_started())

    started_timer:stop()
    minetest.get_node_timer(started_pos):stop()

    callback()
end)

mtt.register("serialize and deserialize chunk with negative position", function(callback)
    local chunk_pos = { x=-1, y=-1, z=-1 }
    assert(vector.equals(chunk_pos, mapsync.get_chunkpos(negative_pos)))

    local target_chunk_pos = { x=0, y=0, z=0 }

    minetest.set_node(negative_pos, { name = "default:mese", param2 = 12 })

    local offset = copy_chunk(chunk_pos, target_chunk_pos, minetest.get_worldpath() .. "/chunk_negative.zip")
    local node = minetest.get_node(vector.add(negative_pos, offset))
    assert(node.name == "default:mese")
    assert(node.param2 == 12)

    callback()
end)

mtt.register("parse_chunk errors", function(callback)
    -- garbage file
    local garbage_file = minetest.get_worldpath() .. "/garbage.zip"
    assert(minetest.safe_file_write(garbage_file, "this is not a zip file"))

    local ok, chunk = pcall(mapsync.parse_chunk, garbage_file)
    assert(not ok or not chunk)

    -- non-existent file
    ok, chunk = pcall(mapsync.parse_chunk, minetest.get_worldpath() .. "/does-not-exist.zip")
    assert(not ok or not chunk)

    callback()
end)
