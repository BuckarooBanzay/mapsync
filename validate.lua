minetest.register_chatcommand("mapsync_validate", {
    description = "validates all chunks from given backend",
    params = "[backend-name]",
    privs = { mapsync = true },
	func = function(_, param)
        local backend = mapsync.get_backend(param)
        if not backend then
            return true, "backend not found"
        end

        local chunks = backend.list_chunks()
        if not chunks or #chunks == 0 then
            return true, "no chunks found"
        end

        for _, chunk_pos in ipairs(chunks) do
            local manifest = backend.get_manifest(chunk_pos)
            if not manifest then
                return true, "manifest for chunk " .. minetest.pos_to_string(chunk_pos) .. " not found"
            end
        end

        return true, "all good"
	end
})