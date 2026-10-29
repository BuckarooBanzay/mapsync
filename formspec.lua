local FORMNAME = "mapsync:main"

local function esc(str)
	return minetest.formspec_escape(tostring(str))
end

local function format_age(timestamp)
	if not timestamp then
		return "never"
	end
	return string.format("%d s ago", os.difftime(os.time(), timestamp))
end

local function get_formspec(playername)
	local stats = mapsync.get_autosave_stats()
	local player = minetest.get_player_by_name(playername)

	local lines = {
		"Autosave: " .. (mapsync.autosave and "enabled" or "disabled"),
		"Pending chunks: " .. stats.pending,
		"Dispatched chunks: " .. stats.dispatched,
		"Failed chunks: " .. stats.failed,
		"Last dispatch: " .. format_age(stats.last_dispatch),
		"",
		"Backends:"
	}

	local names = {}
	for name in pairs(mapsync.get_backends()) do
		table.insert(names, name)
	end
	table.sort(names)

	local current_backend = player and mapsync.select_backend(mapsync.get_chunkpos(player:get_pos()))
	for _, name in ipairs(names) do
		local def = mapsync.get_backend(name)
		table.insert(lines, string.format("  %s [%s] %s%s",
			name, def.type, tostring(def.path),
			current_backend == def and " (current chunk)" or ""
		))
	end
	if #names == 0 then
		table.insert(lines, "  <none>")
	end

	local data_backend = mapsync.get_data_backend()
	table.insert(lines, "")
	table.insert(lines, "Data backend: " .. (data_backend and tostring(data_backend.path) or "<none>"))

	local text = {}
	for i, line in ipairs(lines) do
		text[i] = esc(line)
	end

	return table.concat({
		"formspec_version[4]",
		"size[10,9]",
		"label[0.5,0.6;Mapsync]",
		"textarea[0.5,1;9,6.2;;;", table.concat(text, "\n"), "]",
		"checkbox[0.5,7.7;autosave;Autosave;", tostring(mapsync.autosave), "]",
		"button[5.5,7.2;1.9,0.8;refresh;Refresh]",
		"button_exit[7.6,7.2;1.9,0.8;close;Close]",
	})
end

function mapsync.show_formspec(playername)
	minetest.show_formspec(playername, FORMNAME, get_formspec(playername))
end

minetest.register_chatcommand("mapsync", {
	description = "shows the mapsync status and settings",
	privs = { mapsync = true },
	func = function(name)
		mapsync.show_formspec(name)
		return true
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= FORMNAME then
		return
	end

	local name = player:get_player_name()
	if not minetest.check_player_privs(name, { mapsync = true }) then
		return true
	end

	if fields.autosave ~= nil then
		mapsync.set_autosave(fields.autosave == "true")
		mapsync.show_formspec(name)
	elseif fields.refresh then
		mapsync.show_formspec(name)
	end
	return true
end)
