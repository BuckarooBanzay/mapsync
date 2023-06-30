local global_env = ...

local function get_json_path(prefix, chunk_pos)
    return prefix .. "/chunk_" .. minetest.pos_to_string(chunk_pos) .. ".json"
end

local function get_path(prefix, chunk_pos)
    return prefix .. "/chunk_" .. minetest.pos_to_string(chunk_pos) .. ".zip"
end

mapsync.register_backend_handler("patch", {
    validate_config = function(backend_def)
        assert(type(backend_def.patch_path) == "string")
        assert(type(backend_def.path) == "string")
    end,
    save_chunk = function(backend_def, chunk_pos)
        local baseline_chunk = mapsync.parse_chunk(get_path(backend_def.path, chunk_pos))
        local filename = get_json_path(backend_def.patch_path, chunk_pos)
        local f = global_env.io.open(filename, "w")

        mapsync.create_diff(baseline_chunk, chunk_pos, function(changed_node)
            f:write(minetest.write_json(changed_node) .. '\n')
        end)

        f:close()
        return true
    end,
    load_chunk = function(backend_def, chunk_pos, vmanip)
        -- load baseline chunk (might be non-existent)
        mapsync.deserialize_chunk(chunk_pos, get_path(backend_def.path, chunk_pos), vmanip)

        -- load diff if available
        local f = io.open(get_json_path(backend_def.patch_path, chunk_pos), "r")
        if not f then
            -- no diff
            return true
        end

        local changed_nodes = {}
        for line in f:lines() do
            local changed_node = minetest.parse_json(line)
            if changed_node then
                table.insert(changed_nodes, changed_node)
            end
        end
        f:close()

        -- apply diff
        return mapsync.apply_diff(chunk_pos, changed_nodes)
    end,
    get_manifest = function(backend_def, chunk_pos)
        mapsync.get_manifest(get_path(backend_def.path, chunk_pos))
    end,
    apply_patches = function(backend_def, callback)
        -- load all chunks and save back to fs
        local files = minetest.get_dir_list(backend_def.patch_path, false)

        -- collect all chunks
        local chunk_pos_list = {}
        for _, filename in ipairs(files) do
            if string.match(filename, "^[chunk_(].*[).json]$") then
                local pos_str = string.gsub(filename, "chunk_", "")
                pos_str = string.gsub(pos_str, ".json", "")

                local chunk_pos = minetest.string_to_pos(pos_str)
                table.insert(chunk_pos_list, chunk_pos)
            end
        end

        local emerge_count = 0
        for _, chunk_pos in ipairs(chunk_pos_list) do
            mapsync.delete_chunk(chunk_pos)
            mapsync.emerge_chunk(chunk_pos, function()
                -- save emerged chunk
                mapsync.serialize_chunk(chunk_pos, get_path(backend_def.path, chunk_pos))

                -- remove patch file
                local patch_path = get_json_path(backend_def.patch_path, chunk_pos)
                global_env.os.remove(patch_path)

                emerge_count = emerge_count + 1
                if emerge_count < #chunk_pos_list then
                    --- not done yet
                    return
                end
                -- done
                callback(emerge_count)
            end)
        end
    end
})


minetest.register_chatcommand("mapsync_apply_patches", {
    description = "applies all the patches in given backend (defaults to the one at the current position)",
    params = "[backend-name]",
    privs = { mapsync = true },
	func = function(name, backend_name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return
        end

        local pos = player:get_pos()

        local backend_def
        if backend_name and backend_name ~= "" then
            backend_def = mapsync.get_backend(backend_name)
            if not backend_def then
                return true, "Backend not found: '" .. backend_name .. "'"
            end
        else
            local chunk_pos = mapsync.get_chunkpos(pos)
            backend_def = mapsync.select_backend(chunk_pos)
            if not backend_def then
                return true, "Backend for current position not found"
            end
        end

        if backend_def.type ~= "patch" then
            return true, "Backend type is not of type 'patch'"
        end

        local handler = mapsync.select_handler(backend_def)

        -- apply patches back to shadowed backend
        handler.apply_patches(backend_def, function(chunk_count)
            minetest.chat_send_player(name, "Patching done with " .. chunk_count .. " chunk(s)")
        end)

        return true, "Patching started"
	end
})