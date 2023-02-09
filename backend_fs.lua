
mapsync.register_backend_type("fs", function(backend_def)
    assert(type(backend_def.path) == "string")

    backend_def.get_path = backend_def.get_path or function(chunk_pos)
        return backend_def.path .. "/chunk_" .. minetest.pos_to_string(chunk_pos) .. ".zip"
    end

    backend_def.save_chunk = backend_def.save_chunk or function(chunk_pos)
        return mapsync.serialize_chunk(chunk_pos, backend_def.get_path(chunk_pos))
    end

    backend_def.load_chunk = backend_def.load_chunk or function(chunk_pos, vmanip)
        return mapsync.deserialize_chunk(chunk_pos, backend_def.get_path(chunk_pos), vmanip)
    end

    backend_def.get_manifest = backend_def.get_manifest or function(chunk_pos)
        return mapsync.get_manifest(backend_def.get_path(chunk_pos))
    end

    backend_def.list_chunks = backend_def.list_chunks or function()
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
end)