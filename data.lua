local global_env = ...

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