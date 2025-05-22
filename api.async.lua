
mapsync = {
	async_env = true
}

function mapsync.select_backend(chunk_pos)
	return minetest.ipc_get("mapsync:backend")
end
