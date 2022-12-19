local MP = minetest.get_modpath("mapsync")

-- mod namespace
mapsync = {
	pos1 = {},
	pos2 = {},
	version = 1
}

-- secure/insecure environment
local global_env = _G

local ie = minetest.request_insecure_environment and minetest.request_insecure_environment()
if ie then
	print("[mapsync] using insecure environment")
	-- register insecure environment
	global_env = ie
end

dofile(MP.."/api.lua")
dofile(MP.."/encode.lua")

-- pass on global env (secure/insecure)
loadfile(MP.."/functions.lua")(global_env)
loadfile(MP.."/serialize.lua")(global_env)
dofile(MP.."/serialize_mapblock.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP.."/mtt.lua")
end