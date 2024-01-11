local global_env = ...

function mapsync.apply_patches(backend_def, callback, progress_callback)
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
    for i, chunk_pos in ipairs(chunk_pos_list) do
        mapsync.delete_chunk(chunk_pos)
        mapsync.emerge_chunk(chunk_pos, function()
            -- save emerged chunk
            mapsync.serialize_chunk(chunk_pos, mapsync.get_chunk_zip_path(backend_def.path, chunk_pos))

            -- remove patch file
            local patch_path = mapsync.get_chunk_json_path(backend_def.patch_path, chunk_pos)
            global_env.os.remove(patch_path)

            -- report progress
            if type(progress_callback) == "function" then
                progress_callback(chunk_pos, #chunk_pos_list, i)
            end

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

        -- apply patches back to shadowed backend
        mapsync.apply_patches(backend_def, function(chunk_count)
            minetest.chat_send_player(name, "Patching done with " .. chunk_count .. " chunk(s)")
        end, function(chunk_pos, total_count, current_count)
            minetest.chat_send_player(name, "Patched chunk " .. minetest.pos_to_string(chunk_pos) ..
                " progress: " .. current_count .. "/" .. total_count)
        end)

        return true, "Patching started"
	end
})