local global_env = ...

mapsync.register_backend_type("patch", function(backend_def)
    assert(type(backend_def.path) == "string")
    assert(type(backend_def.shadow) == "string")

    local shadow_backend = mapsync.get_backend(backend_def.shadow)
    assert(shadow_backend, "shadow-backend '" .. backend_def.shadow .. "' not found")
    assert(shadow_backend.type == "fs", "patch backend can only shadow a 'fs' backend")

    backend_def.get_path = function(chunk_pos)
        return backend_def.path .. "/chunk_" .. minetest.pos_to_string(chunk_pos) .. ".json"
    end

    backend_def.save_chunk = function(chunk_pos)
        local baseline_chunk = mapsync.parse_chunk(shadow_backend.get_path(chunk_pos))
        local filename = backend_def.get_path(chunk_pos)
        local f = global_env.io.open(filename, "w")

        mapsync.create_diff(baseline_chunk, chunk_pos, function(changed_node)
            f:write(minetest.write_json(changed_node) .. '\n')
        end)

        f:close()
        return true
    end

    backend_def.load_chunk = function(chunk_pos, vmanip)
        shadow_backend.load_chunk(chunk_pos, vmanip)
        -- TODO: apply diff if available
    end

    backend_def.get_manifest = shadow_backend.get_manifest
    backend_def.list_chunks = shadow_backend.list_chunks
    backend_def.select = shadow_backend.select

    -- remove shadowed backend
    mapsync.unregister_backend(shadow_backend.name)
end)