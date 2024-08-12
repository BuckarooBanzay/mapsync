-- simple wrapper for travelnet get- and save-operations
-- stores the data in the mapsync-backend if available

local old_get_travelnets = travelnet.get_travelnets
function travelnet.get_travelnets(playername)
    if mapsync.get_data_backend() then
        -- load from data backend
        return mapsync.load_data("travelnet_" .. playername) or {}
    else
        -- use defaults
        return old_get_travelnets(playername)
    end
end

local old_set_travelnets = travelnet.set_travelnets
function travelnet.set_travelnets(playername, travelnets)
    if mapsync.get_data_backend() then
        -- save to data backend
        mapsync.save_data("travelnet_" .. playername, travelnets)
    else
        -- use defaults
        return old_set_travelnets(playername, travelnets)
    end
end

-- ${playername} / ${station_name} => true
local emerged_entries = {}

-- emerge travelnet destinations before the player visits them
local old_show_current_formspec = travelnet.show_current_formspec
function travelnet.show_current_formspec(pos, meta, playername)
    local travelnets = travelnet.get_travelnets(playername)
    local station_network = meta:get_string("station_network")

    local key = playername .. "/" .. station_network
    if not emerged_entries[key] then
        if travelnets and travelnets[station_network] then
            for _, entry in pairs(travelnets[station_network]) do
                minetest.emerge_area(entry.pos, entry.pos)
            end
        end
        emerged_entries[key] = true
    end

    return old_show_current_formspec(pos, meta, playername)
end