-- advtrains compat
-- saves a snapshot of the advtrains-data with the `/mapsync_save_advtrains` command
-- loads the snapshot if available on startup, defaults to the worldfolder if no snapshot found

-- sanity checks
assert(type(advtrains.load_version_4) == "function")
assert(type(advtrains.ndb.save_callback) == "function")
assert(type(advtrains.ndb.load_callback) == "function")
assert(type(advtrains.read_component) == "function")
assert(type(advtrains.save_component) == "function")
assert(type(advtrains.save) == "function")
assert(type(serialize_lib.load_atomic) == "function")
assert(type(serialize_lib.save_atomic_multiple) == "function")
assert(type(advtrains.fpath) == "string")

-- local old_advtrains_read_component = advtrains.read_component
function advtrains.read_component(name)
    assert(name == "version")
    -- currently supported version
    return 4
end

-- local old_advtrains_save_component = advtrains.save_component
function advtrains.save_component()
    -- no-op
end

-- load from data- or world-path
local old_load_atomic = serialize_lib.load_atomic
function serialize_lib.load_atomic(filename, load_callback)
    local relpath = string.sub(filename, #advtrains.fpath + 2)
    local timestamp_storage_key = "advtrains_timestamp_" .. relpath

    -- check world- and snapshot-timestamp
    local snapshot_timestamp = mapsync.load_data("advtrains_timestamp") or 0
    local world_timestamp = mapsync.storage:get_int(timestamp_storage_key)
    -- snapshot exists and has a different timestamp
    local load_snapshot = snapshot_timestamp ~= world_timestamp

    local data_file = mapsync.get_data_file("advtrains_" .. relpath)
    if data_file and load_snapshot then
        -- apply snapshot timestamp to world
        mapsync.storage:set_int(timestamp_storage_key, snapshot_timestamp)
        -- data-snapshot available, load it
        local data_path = mapsync.get_data_file_path("advtrains_" .. relpath)
        minetest.log("action", "[mapsync] loading advtrains data from '" .. data_path ..
            "' snapshot_timestamp: " .. snapshot_timestamp ..
            " world_timestamp: " .. world_timestamp)
        return old_load_atomic(data_path, load_callback)
    else
        -- no data snapshot available, load default from world-folder
        return old_load_atomic(filename, load_callback)
    end
end

local advtrains_parts = {"atlatc.ls", "interlocking.ls", "core.ls", "lines.ls", "ndb4.ls"}

local function copy_advtrains_files()
    if not mapsync.get_data_backend() then
        return false, "no data-backend configured"
    end

    -- copy files to data-directory
    local count = 0
    for _, part in ipairs(advtrains_parts) do
        local path = advtrains.fpath .. "_" .. part
        local src = io.open(path, "rb")
        if not src then
            return false, "open failed for '" .. path .. "'"
        end

        local dst = mapsync.get_data_file("advtrains_" .. part, "wb")
        local data = src:read("*all")
        count = count + #data
        dst:write(data)
        dst:close()
        src:close()
    end
    -- write timestamp
    mapsync.save_data("advtrains_timestamp", os.time())

    minetest.log("action", "[mapsync] saved " .. count .. " bytes of advtrains data")
    return count
end

local old_advtrains_save = advtrains.save
function advtrains.save(remove_players_from_wagons)
    -- save advtrains state
    old_advtrains_save(remove_players_from_wagons)

    if mapsync.autosave then
        -- save to data-directory
        copy_advtrains_files()
    end
end

minetest.register_chatcommand("mapsync_save_advtrains", {
    privs = { mapsync = true },
    func = function()
        -- save advtrains data first
        old_advtrains_save()

        local count, err = copy_advtrains_files()
        if err then
            return false, err
        end

        return true, "saved " .. count .. " bytes of advtrains data"
    end
})