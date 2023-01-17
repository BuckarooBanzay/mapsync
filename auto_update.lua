
local cache = {}

-- updates a chunk if there is a newer version available
function mapsync.update_chunk(chunk_pos)
    -- cache access
    local cache_key = minetest.pos_to_string(chunk_pos)
    if cache[cache_key] then
        return
    end
    cache[cache_key] = true

    -- get backend
    local backend = mapsync.select_backend(chunk_pos)
    if not backend then
        return
    end

    -- get manifest
    local manifest = backend.get_manifest(chunk_pos)
    if not manifest then
        return
    end

    -- retrieve timestamps
    local mod_mtime = manifest.mtime
    local world_mtime = mapsync.get_world_chunk_mtime(chunk_pos)

    if not mod_mtime then
        -- the chunk isn't available in the mod
        return
    end

    if world_mtime and world_mtime >= mod_mtime then
        -- world chunk is same or newer (?) than the one in the mod
        return
    end

    local mapblock_min, mapblock_max = mapsync.get_mapblock_bounds_from_chunk(chunk_pos)
    local min = mapsync.get_mapblock_bounds_from_mapblock(mapblock_min)
    local _, max = mapsync.get_mapblock_bounds_from_mapblock(mapblock_max)

    minetest.log("action", "[mapsync] updating chunk " .. minetest.pos_to_string(chunk_pos))
    minetest.delete_area(min, max)
end

local function check_player_pos(player)
    local ppos = player:get_pos()
    local chunk_pos = mapsync.get_chunkpos(ppos)
    mapsync.check_chunk_update(chunk_pos)
end

local function check_players()
    for _, player in ipairs(minetest.get_connected_players()) do
        check_player_pos(player)
    end
    minetest.after(1, check_players)
end

minetest.after(1, check_players)