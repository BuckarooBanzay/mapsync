
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
    end,

    list_chunks = function(backend_def)
        local files = minetest.get_dir_list(backend_def.path, false)
        local chunks = {}
        for _, filename in ipairs(files) do
            if string.match(filename, "^[chunk_(].*[).zip]$") then
                local pos_str = string.gsub(filename, "chunk_", "")
                pos_str = string.gsub(pos_str, ".zip", "")

                local pos = minetest.string_to_pos(pos_str)
                table.insert(chunks, pos)
            end
        end
        return chunks
    end
})

mapsync.register_data_backend_handler("fs", {
    validate_config = function(data_backend_def)
        assert(type(data_backend_def.path) == "string")
    end,

    save_data = function(data_backend_def, key, value)
        local f = assert(io.open(data_backend_def.path .. "/" .. key, "w"))
        f:write(minetest.serialize(value))
        f:close()
    end,

    load_data = function(data_backend_def, key)
        local f = io.open(data_backend_def.path .. "/" .. key, "r")
        if not f then
            return
        end
        local value = minetest.deserialize(f:read("*all"))
        f:close()
        return value
    end
})