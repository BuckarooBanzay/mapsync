local global_env = ...

local function get_path(prefix, chunk_pos)
    return prefix .. "/chunk_" .. minetest.pos_to_string(chunk_pos) .. ".zip"
end

mapsync.register_backend_handler("fs", {
    validate_config = function(backend_def)
        assert(type(backend_def.path) == "string")
    end,
    save_chunk = function(backend_def, chunk_pos)
        return mapsync.serialize_chunk(chunk_pos, get_path(backend_def.path, chunk_pos))
    end,

    load_chunk = function(backend_def, chunk_pos, vmanip)
        return mapsync.deserialize_chunk(chunk_pos, get_path(backend_def.path, chunk_pos), vmanip)
    end,

    get_manifest = function(backend_def, chunk_pos)
        return mapsync.get_manifest(get_path(backend_def.path, chunk_pos))
    end
})

mapsync.register_data_backend_handler("fs", {
    validate_config = function(data_backend_def)
        assert(type(data_backend_def.path) == "string")
    end,

    save_data = function(data_backend_def, key, value)
        local f = assert(global_env.io.open(data_backend_def.path .. "/" .. key .. ".lua", "w"))
        f:write(minetest.serialize(value))
        f:close()
    end,

    load_data = function(data_backend_def, key)
        local f = global_env.io.open(data_backend_def.path .. "/" .. key .. ".lua", "r")
        if not f then
            return
        end
        local value = minetest.deserialize(f:read("*all"))
        f:close()
        return value
    end
})