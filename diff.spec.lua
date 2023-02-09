
mtt.register("diff", function(callback)

    local chunk_pos = { x=0, y=0, z=0 }
    local filename = minetest.get_worldpath() .. "/mychunk.zip"

    -- serialize existing chunk
    assert(mapsync.serialize_chunk(chunk_pos, filename))
    local baseline_chunk, err_msg = mapsync.parse_chunk(filename)
    assert(baseline_chunk)
    assert(not err_msg)

    -- change things
    minetest.set_node({ x=10, y=0, z=0 }, { name = "default:mese" })

    minetest.set_node({ x=10, y=1, z=0 }, { name = "default:chest" })
    local meta = minetest.get_meta({ x=10, y=1, z=0 })
    meta:set_int("x", 10)

    local changed_nodes = {}
    local node_callback = function(node)
        table.insert(changed_nodes, node)
        -- print(dump(node))
    end

    -- create and validate diff
    local success = mapsync.create_diff(baseline_chunk, chunk_pos, node_callback, {
        -- ignore light-changes (artificial and natural)
        param1_max_delta = 256
    })
    assert(success)

    local changes = 0
    for _, changed_node in ipairs(changed_nodes) do
        if changed_node.name == "default:mese" then
            changes = changes + 1
        elseif changed_node.name == "default:chest" then
            changes = changes + 1
            assert(changed_node.meta.fields.x == "10")
        else
            callback("unexpected change")
        end
    end
    assert(changes == 2)

    -- apply changes to another chunk
    chunk_pos = { x=0, y=1, z=0 }

    success = mapsync.apply_diff(chunk_pos, changed_nodes)
    assert(success)

    assert(minetest.get_node({ x=10, y=80, z=0 }).name == "default:mese")
    assert(minetest.get_node({ x=10, y=81, z=0 }).name == "default:chest")
    meta = minetest.get_meta({ x=10, y=81, z=0 })
    assert(meta:get_int("x") == 10)

    callback()
end)