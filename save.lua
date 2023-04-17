
local function save_worker(ctx)
    local chunk_pos = ctx.iterator()
    if not chunk_pos then
        -- done
        minetest.chat_send_player(ctx.playername, "Async saving done with " .. ctx.count .. " chunks")
    else
        -- save pos
        local success, err_msg = mapsync.save(chunk_pos)
        if not success then
            minetest.chat_send_player(
                ctx.playername,
                "Saving of chunk " .. minetest.pos_to_string(chunk_pos) .. "failed with: " .. err_msg
            )
        else
            minetest.chat_send_player(
                ctx.playername,
                "Saving of chunk " .. minetest.pos_to_string(chunk_pos) .. " done (count: " .. ctx.count .. ")"
            )
            ctx.count = ctx.count + 1

            -- re-schedule
            minetest.after(0, save_worker, ctx)
        end
    end
end

minetest.register_chatcommand("mapsync_save", {
    description = "saves the current chunk or a range around the current chunk (cubic)",
    params = "[chunk-range]",
    privs = { mapsync = true },
	func = function(name, param)
        local player = minetest.get_player_by_name(name)
        if not player then
            return
        end

        local range = tonumber(param) or 0
        local ppos = player:get_pos()
        local chunk_pos = mapsync.get_chunkpos(ppos)
        local chunk_pos1 = vector.subtract(chunk_pos, range)
        local chunk_pos2 = vector.add(chunk_pos, range)

        if range == 0 then
            -- just the one block
            local success, err_msg = mapsync.save(chunk_pos)
            if success then
                return true, "Saved chunk: " .. minetest.pos_to_string(chunk_pos)
            else
                return true, "Error saving chunk: " ..
                    minetest.pos_to_string(chunk_pos) .. ", error: " ..
                    (err_msg and err_msg or "<no message>")
            end
        end

        -- multiple blocks, execute async
        minetest.after(0, save_worker, {
            playername = name,
            count = 0,
            iterator = mapsync.pos_iterator(chunk_pos1, chunk_pos2),
        })

        return true, "dispatched saving to worker with range of " .. range .. " chunks around the current center"
	end
})

function mapsync.save(chunk_pos)
    local backend_def = mapsync.select_backend(chunk_pos)
    if not backend_def then
        return true, "No backend available"
    end

    local handler = mapsync.select_handler(backend_def)
    return handler.save_chunk(backend_def, chunk_pos)
end