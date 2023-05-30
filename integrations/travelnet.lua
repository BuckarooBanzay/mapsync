
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