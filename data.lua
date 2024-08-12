local global_env = ...

-- save simple key-value data (tables, strings, etc)
function mapsync.save_data(key, value)
    local data_backend_def = mapsync.get_data_backend()
    if not data_backend_def then
        -- no data backend defined
        return
    end

    local f = assert(global_env.io.open(data_backend_def.path .. "/" .. key .. ".lua", "w"))
    f:write(minetest.serialize(value))
    f:close()
end

-- load simple key-value data
-- returns nil if not available or not existing
function mapsync.load_data(key)
    local data_backend_def = mapsync.get_data_backend()
    if not data_backend_def then
        -- no data backend defined
        return
    end

    local f = global_env.io.open(data_backend_def.path .. "/" .. key .. ".lua", "r")
    if not f then
        return
    end
    local value = minetest.deserialize(f:read("*all"))
    f:close()
    return value
end

-- returns a file to write to in the data-storage, nil if not available
function mapsync.get_data_file(key, mode)
    -- default to read
    mode = mode or "r"

    local data_backend_def = mapsync.get_data_backend()
    if not data_backend_def then
        -- no data backend defined
        return
    end

    return global_env.io.open(data_backend_def.path .. "/" .. key, mode)
end