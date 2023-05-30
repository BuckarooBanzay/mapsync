local global_env = ...

local function get_json_path(backend_def, chunk_pos)
    return backend_def.path .. "/chunk_" .. minetest.pos_to_string(chunk_pos) .. ".json"
end

local function get_path(backend_def, chunk_pos)
    return backend_def.path .. "/chunk_" .. minetest.pos_to_string(chunk_pos) .. ".json"
end

mapsync.register_backend_handler("patch", {
    validate_config = function(backend_def)
        assert(type(backend_def.path) == "string")
        assert(type(backend_def.shadow) == "string")
        local shadow_def = mapsync.get_backend(backend_def.shadow)
        assert(shadow_def)
        assert(shadow_def.type == "fs")
    end,
    save_chunk = function(backend_def, chunk_pos)
        local baseline_chunk = mapsync.parse_chunk(get_path(backend_def, chunk_pos))
        local filename = get_json_path(backend_def, chunk_pos)
        local f = global_env.io.open(filename, "w")

        mapsync.create_diff(baseline_chunk, chunk_pos, function(changed_node)
            f:write(minetest.write_json(changed_node) .. '\n')
        end)

        f:close()
        return true
    end,
    load_chunk = function(backend_def, chunk_pos, vmanip)
        -- TODO: apply diff if available
        return mapsync.deserialize_chunk(chunk_pos, get_path(backend_def, chunk_pos), vmanip)
    end,
    get_manifest = function(backend_def, chunk_pos)
        mapsync.get_manifest(get_path(backend_def, chunk_pos))
    end
})
