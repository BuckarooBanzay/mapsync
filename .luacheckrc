globals = {
	"mapsync",
	"worldedit",
	"minetest",
	"travelnet"
}

read_globals = {
	-- Stdlib
	string = {fields = {"split", "trim"}},
	table = {fields = {"copy", "getn"}},

	-- Minetest
	"vector", "ItemStack",
	"dump", "dump2",
	"VoxelArea",

	-- mods
	"mtzip",

	-- testing
	"mtt"
}
