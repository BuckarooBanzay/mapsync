minetest.register_chatcommand("mapsync_validate", {
    description = "validates all chunks from given backend",
    params = "[backend-name]",
    privs = { mapsync = true },
	func = function(_, param)
        local success, err = mapsync.validate(param)
        if success then
            return true, "all good"
        else
            return true, "Error: " .. err
        end
	end
})

function mapsync.validate(backend_name)
    local backend_def = mapsync.get_backend(backend_name)
    if not backend_def then
        return false, "backend not found"
    end

    local handler = mapsync.select_handler(backend_def)
    if type(handler.list_chunks) ~= "function" then
        return false, "Backend does not support enumeration"
    end

    local chunks = handler.list_chunks(backend_def)
    if not chunks or #chunks == 0 then
        return true -- no chunks to validate
    end

    for _, chunk_pos in ipairs(chunks) do
        local manifest = handler.get_manifest(backend_def, chunk_pos)
        if not manifest then
            return false, "manifest for chunk " .. minetest.pos_to_string(chunk_pos) .. " not found"
        end
    end

    return true -- all good
end