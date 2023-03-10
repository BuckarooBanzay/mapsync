globals = {
	"mapsync",
	"worldedit",
	"minetest"
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
