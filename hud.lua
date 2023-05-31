
-- player => { name => id }
local hud_data = {}

local hud_position = { x = 0.1, y = 0.9 }

local function setup_hud(player)
	local data = {}

	data.img = player:hud_add({
		hud_elem_type = "image",
		position = hud_position,
		text = "mapsync_loaded.png",
		offset = {x = 0,   y = 0},
		alignment = { x = -1, y = 0},
		scale = {x = 2, y = 2}
	})

	data.text = player:hud_add({
		hud_elem_type = "text",
		position = hud_position,
		number = 0x00ff00,
		text = "",
		offset = {x = 0,   y = -8},
		alignment = { x = 1, y = 0},
		scale = {x = 2, y = 2}
	})

	data.text2 = player:hud_add({
		hud_elem_type = "text",
		position = hud_position,
		number = 0x00ff00,
		text = "",
		offset = {x = 0,   y = 8},
		alignment = { x = 1, y = 0},
		scale = {x = 2, y = 2}
	})

	hud_data[player:get_player_name()] = data
end

local function update_player_hud(player)

	local playername = player:get_player_name()
	local data = hud_data[playername]
	if not data then
		return
	end

	local ppos = player:get_pos()
	local chunk_pos = mapsync.get_chunkpos(ppos)
	local backend = mapsync.select_backend(chunk_pos)

	local txt = "Mapsync: "
	if mapsync.autosave then
		txt = txt .. "autosaving"
		player:hud_change(data.img, "text", "mapsync_autosave.png")
	else
		txt = txt .. "ready"
		player:hud_change(data.img, "text", "mapsync_loaded.png")
	end

	-- provide some info about the current chunk and available backend
	local txt2 = string.format("Chunk: %s, Backend: ", minetest.pos_to_string(chunk_pos))

	if backend then
		txt2 = txt2 .. string.format("'%s' [%s]", backend.name, backend.type)
	else
		txt2 = txt2 .. "<none>"
	end

	if backend then
		-- backend available
		player:hud_change(data.text2, "number", 0x00FF00)
	else
		-- no backend available
		player:hud_change(data.text2, "number", 0xFF0000)
	end

	player:hud_change(data.text, "text", txt)
	player:hud_change(data.text2, "text", txt2)
end

-- init

local function update_hud()
	for _, player in ipairs(minetest.get_connected_players()) do
		if minetest.check_player_privs(player, "mapsync") then
			update_player_hud(player)
		end
	end
	minetest.after(0.2, update_hud)
end
minetest.after(1, update_hud)

minetest.register_on_joinplayer(function(player)
	if minetest.check_player_privs(player, "mapsync") then
		setup_hud(player)
		update_player_hud(player)
	end
end)

-- priv updates
if minetest.register_on_priv_grant then
	minetest.register_on_priv_grant(function(name, granter, priv)
		local player = minetest.get_player_by_name(name)
		if priv == "mapsync" and player and granter then
			setup_hud(player)
		end
	end)
end