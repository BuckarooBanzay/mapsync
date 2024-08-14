assert(type(hyperloop.Stations) == "table")
assert(type(hyperloop.Elevators) == "table")

local function save()
    mapsync.save_data("hyperloop_stations", hyperloop.Stations:serialize())
    mapsync.save_data("hyperloop_elevators", hyperloop.Elevators:serialize())
end

-- save on shutdown
minetest.register_on_shutdown(save)

local function load()
    local data = mapsync.load_data("hyperloop_stations")
    if data then
        hyperloop.Stations:deserialize(data)
    end
    data = mapsync.load_data("hyperloop_elevators")
    if data then
        hyperloop.Elevators:deserialize(data)
    end
end

-- load on startup
minetest.register_on_mods_loaded(load)