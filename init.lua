local MP = minetest.get_modpath("mapsync")
local storage = minetest.get_mod_storage()

-- mod namespace
mapsync = {
	-- current major version
	version = 1,
	-- mod storage
	storage = storage,
	-- autosave feature
	autosave = storage:get_int("autosave") == 1,
}

-- secure/insecure environment
local global_env = _G
local ie = minetest.request_insecure_environment and minetest.request_insecure_environment()
if ie then
	minetest.log("action", "[mapsync] using insecure environment")
	-- register insecure environment
	global_env = ie
end

-- api surface
dofile(MP.."/api.lua")
dofile(MP.."/privs.lua")

-- utilities / helpers
dofile(MP.."/encoding.lua")
dofile(MP.."/serialize_mapblock.lua")
dofile(MP.."/deserialize_mapblock.lua")
dofile(MP.."/localize_nodeids.lua")

-- save/load
dofile(MP.."/auto_save.lua")
dofile(MP.."/auto_update.lua")
dofile(MP.."/save.lua")
dofile(MP.."/mapgen.lua")

-- hud stuff
dofile(MP.."/hud.lua")

-- pass on global env (secure/insecure)
loadfile(MP.."/functions.lua")(global_env)
loadfile(MP.."/serialize_chunk.lua")(global_env)
loadfile(MP.."/deserialize_chunk.lua")(global_env)

-- testing
if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP.."/api.spec.lua")
	dofile(MP.."/serialize_chunk.spec.lua")
end