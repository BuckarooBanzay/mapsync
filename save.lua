
minetest.register_chatcommand("mapsync_save", {
    description = "saves the current chunk",
    privs = { mapsync = true },
	func = function(name)
        local player = minetest.get_player_by_name(name)
        if not player then
            return
        end

        local ppos = player:get_pos()
        local chunk_pos = mapsync.get_chunkpos(ppos)
        local backend = mapsync.select_backend(chunk_pos)
        if not backend then
            return true, "No backend available"
        end

        local success, err_msg = backend.save_chunk(chunk_pos)
        if success then
            return true, "Saved chunk: " .. minetest.pos_to_string(chunk_pos)
        else
            return true, "Error saving chunk: " ..
                minetest.pos_to_string(chunk_pos) .. ", error: " ..
                (err_msg and err_msg or "<no message>")
        end
	end
})
