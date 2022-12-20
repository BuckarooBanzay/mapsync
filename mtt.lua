
mtt.register("backend selection", function(callback)
    mapsync.register_backend("my-backend", {
        path = minetest.get_worldpath() .. "/mymap",
        select = function(chunk_pos)
            return chunk_pos.y < 10 and chunk_pos.y > -10
        end
    })

    local backend = mapsync.select_backend({x=0, y=0, z=0})
    assert(backend.name == "my-backend")

    backend = mapsync.select_backend({x=0, y=10, z=0})
    assert(not backend)

    callback()
end)

local pos = { x=0, y=0, z=0 }
mtt.emerge_area(pos, pos)
mtt.register("serialize and deserialize chunk", function(callback)

    -- vars
    local chunk_pos = {x=0, y=0, z=0}
    local filename = minetest.get_worldpath() .. "/chunk.zip"
    local node_pos = { x=10, y=5, z=0 }

    -- prepare
    minetest.set_node(node_pos, { name = "default:mese", param2 = 66 })

    local success, err_msg = mapsync.serialize_chunk(chunk_pos, filename)
    assert(success)
    assert(not err_msg)

    local target_chunk_pos = vector.add(chunk_pos, { x=1, y=0, z=0 })
    success, err_msg = mapsync.deserialize_chunk(target_chunk_pos, filename)
    assert(success)
    assert(not err_msg)

    -- assert
    local target_node_pos = vector.add(node_pos, { x=80, y=0, z=0 })
    local node = minetest.get_node(target_node_pos)
    assert(node.name == "default:mese")
    assert(node.param2 == 66)

    callback()
end)