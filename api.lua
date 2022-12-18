
-- name => backend_def
local backends = {}

-- register a map backend
function mapsync.register_backend(name, backend_def)
    backend_def.name = name
    -- default to always-on backend if no selector specified
    backend_def.select = backend_def.select or function() return true end
    backends[name] = backend_def
end

function mapsync.get_backends()
    return backends
end