
minetest.register_chatcommand("mapsync_autosave", {
    description = "enable or disable the autosave feature",
    params = "[on|off]",
    privs = { mapsync = true },
	func = function(_, params)
		if params == "on" then
			mapsync.autosave = true
			mapsync.storage:set_int("autosave", 1)
			return true, "Autosave enabled"
		else
			mapsync.autosave = false
			mapsync.storage:set_int("autosave", 0)
			return true, "Autosave disabled"
		end
	end
})
