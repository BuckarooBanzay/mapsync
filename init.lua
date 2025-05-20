local MP = minetest.get_modpath("mapsync")
local storage = minetest.get_mod_storage()

-- mod namespace
mapsync = {
	-- current major version
	version = 1,
	-- time of last map change (for auto_updating / change detection)
	last_mapchange = os.time(),
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
dofile(MP.."/pos_iterator.lua")
dofile(MP.."/encoding.lua")
dofile(MP.."/serialize_mapblock.lua")
dofile(MP.."/deserialize_mapblock.lua")
dofile(MP.."/localize_nodeids.lua")
dofile(MP.."/functions.lua")

-- save/load
dofile(MP.."/auto_save.lua")
dofile(MP.."/auto_update.lua")
dofile(MP.."/save.lua")
loadfile(MP.."/data.lua")(global_env)
dofile(MP.."/load.lua")

if not minetest.register_mapgen_script then
	-- sync mapgen
	dofile(MP.."/mapgen.lua")
else
	-- async mapgen
	minetest.register_mapgen_script(MP.."/api.async.lua")
	minetest.register_mapgen_script(MP.."/pos_iterator.lua")
	minetest.register_mapgen_script(MP.."/encoding.lua")
	minetest.register_mapgen_script(MP.."/functions.lua")
	minetest.register_mapgen_script(MP.."/mapgen.async.lua")

	minetest.register_mapgen_script(MP.."/load.lua")
	minetest.register_mapgen_script(MP.."/parse_chunk.lua")
	minetest.register_mapgen_script(MP.."/deserialize_chunk.lua")
end

-- hud stuff
dofile(MP.."/hud.lua")

-- pass on global env (secure/insecure)
loadfile(MP.."/serialize_chunk.lua")(global_env)
loadfile(MP.."/parse_chunk.lua")(global_env)
loadfile(MP.."/deserialize_chunk.lua")(global_env)

-- mod integrations
if minetest.get_modpath("travelnet") then
	dofile(MP.."/integrations/travelnet.lua")
end

if minetest.get_modpath("advtrains") then
	dofile(MP.."/integrations/advtrains.lua")
end

if minetest.get_modpath("hyperloop") then
	dofile(MP.."/integrations/hyperloop.lua")
end

if minetest.get_modpath("elevator") then
	dofile(MP.."/integrations/elevator.lua")
end

-- testing
if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP.."/init.spec.lua")
	dofile(MP.."/functions.spec.lua")
	dofile(MP.."/data.spec.lua")
	dofile(MP.."/api.spec.lua")
	dofile(MP.."/serialize_chunk.spec.lua")
end
