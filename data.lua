
function mapsync.save_data(key, value)
    local data_backend_def = mapsync.get_data_backend()
    local data_handler = mapsync.select_data_handler(data_backend_def)
    if data_handler then
        data_handler.save_data(data_backend_def, key, value)
    end
end

function mapsync.load_data(key)
    local data_backend_def = mapsync.get_data_backend()
    local data_handler = mapsync.select_data_handler(data_backend_def)
    if data_handler then
        return data_handler.load_data(data_backend_def, key)
    end
end