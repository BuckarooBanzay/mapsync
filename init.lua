local MP = minetest.get_modpath("mapsync")

-- mod namespace
mapsync = {
	pos1 = {},
	pos2 = {}
}

-- secure/insecure environment
local global_env = _G

local ie = minetest.request_insecure_environment and minetest.request_insecure_environment()
if ie then
	print("[mapsync] using insecure environment")
	-- register insecure environment
	global_env = ie
end

-- pass on global env (secure/insecure)
loadfile(MP.."/functions.lua")(global_env)
dofile(MP.."/api.lua")

if minetest.get_modpath("mtt") and mtt.enabled then
	dofile(MP.."/mtt.lua")
end